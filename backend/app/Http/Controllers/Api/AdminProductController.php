<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class AdminProductController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $perPage = $request->input('per_page', 20);
        $sortBy = $request->input('sort_by', 'created_at');
        $sortOrder = $request->input('sort_order', 'desc');

        $query = Product::query()->with('category:id,name,slug');

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->has('is_active')) {
            $query->where('is_active', (bool) $request->boolean('is_active'));
        }

        $allowedSorts = ['created_at', 'price', 'name', 'rating', 'stock'];
        if (in_array($sortBy, $allowedSorts, true)) {
            $query->orderBy($sortBy, $sortOrder === 'asc' ? 'asc' : 'desc');
        }

        $products = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $products,
        ]);
    }

    public function show(int $id): JsonResponse
    {
        $product = Product::with('category:id,name,slug')->find($id);

        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $product,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = $this->validator($request->all());

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();
        $data['slug'] = $data['slug'] ?? Str::slug($data['name']);

        $product = Product::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Product created successfully',
            'data' => $product->load('category:id,name,slug'),
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found',
            ], 404);
        }

        $validator = $this->validator($request->all(), $product->id);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();
        if (!empty($data['name']) && empty($data['slug'])) {
            $data['slug'] = Str::slug($data['name']);
        }

        $product->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Product updated successfully',
            'data' => $product->load('category:id,name,slug'),
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found',
            ], 404);
        }

        $product->delete();

        return response()->json([
            'success' => true,
            'message' => 'Product deleted successfully',
        ]);
    }

    /**
     * Upload a product image and return its public URL.
     */
    public function uploadImage(Request $request): JsonResponse
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,jpg,png,webp|max:5120',
        ]);

        $path = $request->file('image')->store('products', 'public');
        $url  = url(Storage::url($path));

        return response()->json(['success' => true, 'url' => $url]);
    }

    protected function validator(array $data, ?int $productId = null)
    {
        $uniqueSlugRule = 'unique:products,slug';
        if ($productId) {
            $uniqueSlugRule .= ',' . $productId;
        }

        return Validator::make($data, [
            'name'          => 'required|string|max:255',
            'slug'          => ['nullable', 'string', 'max:255', $uniqueSlugRule],
            'description'   => 'nullable|string',
            'price'         => 'required|numeric|min:0',
            'original_price' => 'nullable|numeric|min:0',
            'stock'         => 'required|integer|min:0',
            'is_active'     => 'nullable|boolean',
            'is_featured'   => 'nullable|boolean',
            'images'        => 'nullable|array',
            'images.*'      => 'string|max:1000',
            'category_id'   => 'nullable|integer|exists:categories,id',
            'rating'        => 'nullable|numeric|min:0|max:5',
            'reviews_count' => 'nullable|integer|min:0',
        ]);
    }
}
