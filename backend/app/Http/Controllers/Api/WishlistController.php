<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Wishlist;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WishlistController extends Controller
{
    /**
     * Get all wishlisted products for the authenticated customer.
     */
    public function index(Request $request): JsonResponse
    {
        $customer = $request->user();

        $items = Wishlist::where('customer_id', $customer->id)
            ->with('product:id,name,slug,price,original_price,images,stock,rating,reviews_count,is_active')
            ->get()
            ->map(fn($w) => $w->product)
            ->filter();

        return response()->json([
            'success' => true,
            'data'    => $items->values(),
        ]);
    }

    /**
     * Toggle a product in the wishlist. Returns 201 (added) or 200 (removed).
     */
    public function toggle(Request $request, int $productId): JsonResponse
    {
        $customer = $request->user();

        $existing = Wishlist::where('customer_id', $customer->id)
            ->where('product_id', $productId)
            ->first();

        if ($existing) {
            $existing->delete();
            return response()->json(['success' => true, 'message' => 'Removed from wishlist.', 'wishlisted' => false]);
        }

        // Verify product exists
        $product = Product::active()->find($productId);
        if (!$product) {
            return response()->json(['success' => false, 'message' => 'Product not found.'], 404);
        }

        Wishlist::create(['customer_id' => $customer->id, 'product_id' => $productId]);

        return response()->json(['success' => true, 'message' => 'Added to wishlist.', 'wishlisted' => true], 201);
    }

    /**
     * Check if a product is wishlisted.
     */
    public function status(Request $request, int $productId): JsonResponse
    {
        $wishlisted = Wishlist::where('customer_id', $request->user()->id)
            ->where('product_id', $productId)
            ->exists();

        return response()->json(['success' => true, 'wishlisted' => $wishlisted]);
    }
}
