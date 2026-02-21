<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class AdminCategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = Category::withCount('products')->orderBy('name')->get();

        return response()->json(['success' => true, 'data' => $categories]);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name'      => 'required|string|max:255|unique:categories,name',
            'slug'      => 'nullable|string|max:255|unique:categories,slug',
            'icon'      => 'nullable|string|max:100',
            'color'     => 'nullable|string|max:20',
            'parent_id' => 'nullable|integer|exists:categories,id',
        ]);

        $data         = $request->only(['name', 'slug', 'icon', 'color', 'parent_id']);
        $data['slug'] = $data['slug'] ?? Str::slug($data['name']);

        $category = Category::create($data);

        return response()->json(['success' => true, 'data' => $category->loadCount('products')], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $category = Category::find($id);
        if (!$category) {
            return response()->json(['success' => false, 'message' => 'Category not found.'], 404);
        }

        $request->validate([
            'name'      => 'sometimes|string|max:255|unique:categories,name,' . $id,
            'slug'      => 'nullable|string|max:255|unique:categories,slug,' . $id,
            'icon'      => 'nullable|string|max:100',
            'color'     => 'nullable|string|max:20',
            'parent_id' => 'nullable|integer|exists:categories,id',
        ]);

        $data = $request->only(['name', 'slug', 'icon', 'color', 'parent_id']);
        if (!empty($data['name']) && empty($data['slug'])) {
            $data['slug'] = Str::slug($data['name']);
        }

        $category->update($data);

        return response()->json(['success' => true, 'data' => $category->loadCount('products')]);
    }

    public function destroy(int $id): JsonResponse
    {
        $category = Category::find($id);
        if (!$category) {
            return response()->json(['success' => false, 'message' => 'Category not found.'], 404);
        }

        $category->delete();

        return response()->json(['success' => true, 'message' => 'Category deleted.']);
    }
}
