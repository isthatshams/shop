<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CartItem;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    /**
     * Get the current customer's cart.
     */
    public function index(Request $request): JsonResponse
    {
        $customer = $request->user();

        $items = CartItem::where('customer_id', $customer->id)
            ->with('product:id,name,slug,price,original_price,images,stock,is_active')
            ->get();

        $subtotal = $items->sum(fn($item) => $item->product->price * $item->quantity);
        $shipping = $subtotal > 100 ? 0 : ($subtotal > 0 ? 9.99 : 0);

        return response()->json([
            'success' => true,
            'data' => [
                'items'    => $items->map(fn($item) => [
                    'id'       => $item->id,
                    'product'  => $item->product,
                    'quantity' => $item->quantity,
                ]),
                'subtotal' => round($subtotal, 2),
                'shipping' => round($shipping, 2),
                'total'    => round($subtotal + $shipping, 2),
                'count'    => $items->sum('quantity'),
            ],
        ]);
    }

    /**
     * Add an item to the cart (or update quantity if already exists).
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'product_id' => 'required|integer|exists:products,id',
            'quantity'   => 'required|integer|min:1|max:100',
        ]);

        $customer = $request->user();
        $product  = Product::active()->find($request->product_id);

        if (!$product) {
            return response()->json(['success' => false, 'message' => 'Product not found or inactive.'], 404);
        }

        if ($product->stock < $request->quantity) {
            return response()->json(['success' => false, 'message' => 'Not enough stock available.'], 422);
        }

        $item = CartItem::updateOrCreate(
            ['customer_id' => $customer->id, 'product_id' => $product->id],
            ['quantity'    => $request->quantity],
        );

        return response()->json([
            'success' => true,
            'message' => 'Item added to cart.',
            'data'    => $item->load('product:id,name,slug,price,original_price,images,stock'),
        ], 201);
    }

    /**
     * Update the quantity of a cart item.
     */
    public function update(Request $request, int $productId): JsonResponse
    {
        $request->validate(['quantity' => 'required|integer|min:1|max:100']);

        $customer = $request->user();
        $item     = CartItem::where('customer_id', $customer->id)
            ->where('product_id', $productId)
            ->first();

        if (!$item) {
            return response()->json(['success' => false, 'message' => 'Item not in cart.'], 404);
        }

        $item->update(['quantity' => $request->quantity]);

        return response()->json([
            'success' => true,
            'message' => 'Cart updated.',
            'data'    => $item->load('product:id,name,slug,price,original_price,images,stock'),
        ]);
    }

    /**
     * Remove a single item from the cart.
     */
    public function destroy(int $productId, Request $request): JsonResponse
    {
        $customer = $request->user();

        $deleted = CartItem::where('customer_id', $customer->id)
            ->where('product_id', $productId)
            ->delete();

        if (!$deleted) {
            return response()->json(['success' => false, 'message' => 'Item not found in cart.'], 404);
        }

        return response()->json(['success' => true, 'message' => 'Item removed from cart.']);
    }

    /**
     * Clear the entire cart.
     */
    public function clear(Request $request): JsonResponse
    {
        CartItem::where('customer_id', $request->user()->id)->delete();

        return response()->json(['success' => true, 'message' => 'Cart cleared.']);
    }
}
