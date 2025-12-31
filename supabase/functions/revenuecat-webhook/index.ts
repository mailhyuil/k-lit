import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface RevenueCatEvent {
  id: string;
  type: string;
  app_user_id: string;
  product_id?: string;
  transaction_id?: string;
  price?: number;
  currency?: string;
  entitlement_ids?: string[];
  // ... other properties
}

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const secret = Deno.env.get("REVENUECAT_WEBHOOK_SECRET");
  const signature = req.headers.get("Authorization");

  if (!secret || signature !== `Bearer ${secret}`) {
    return new Response("Unauthorized", { status: 401 });
  }

  try {
    const payload = await req.json();
    const event = payload.event as RevenueCatEvent;

    console.log("Received RevenueCat event:", JSON.stringify(event, null, 2));

    if (
      (event.type === "INITIAL_PURCHASE" ||
        event.type === "RENEWAL" ||
        event.type === "NON_RENEWING_PURCHASE") &&
      event.product_id
    ) {
      const supabase = createClient(
        Deno.env.get("SUPABASE_URL") ?? "",
        Deno.env.get("SUPABASE_SECRET_KEY") ?? "",
      );
      const userId = event.app_user_id;
      const rcIdentifier = event.product_id;

      // Find the collection that matches the RevenueCat product identifier
      const { data: collection, error: collectionError } = await supabase
        .from("collections")
        .select("id")
        .eq("rc_identifier", rcIdentifier)
        .single();

      if (collectionError) {
        console.error(
          "Error fetching collection for rc_identifier:",
          rcIdentifier,
          collectionError,
        );
      } else if (collection) {
        const collectionId = collection.id;

        // 1. Create the purchase record
        const purchaseRecord = {
          user_id: userId,
          collection_id: collectionId,
          product_id: rcIdentifier,
          transaction_id: event.transaction_id,
          source: "revenuecat",
          amount_cents: event.price ? Math.round(event.price * 100) : undefined,
          currency: event.currency,
          status: "completed",
        };

        const { error: purchaseError } = await supabase
          .from("purchases")
          .insert(purchaseRecord);

        if (purchaseError) {
          console.error("Error inserting purchase record:", purchaseError);
          // Decide if you should stop or continue despite the error
        } else {
          console.log(
            "Successfully inserted purchase record for user:",
            userId,
            "and collection:",
            collectionId,
          );
        }

        // 2. Insert the entitlement for the user and collection
        const { error: insertError } = await supabase.from("entitlements")
          .insert({
            user_id: userId,
            collection_id: collectionId,
            source: "purchase", // or 'subscription'
            product_id: rcIdentifier,
          });

        if (insertError) {
          console.error("Error inserting entitlement:", insertError);
        }

        else {
          console.log(
            "Successfully inserted entitlement for user:",
            userId,
            "and collection:",
            collectionId,
          );
        }
      } else {
        console.warn("No collection found for rc_identifier:", rcIdentifier);
      }
    }

    return new Response(JSON.stringify({ received: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("Error processing webhook:", e);
    return new Response("Internal Server Error", { status: 500 });
  }
});
