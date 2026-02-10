<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Create roles
        $superAdmin = Role::firstOrCreate(['name' => 'super_admin', 'guard_name' => 'web']);
        $admin = Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'web']);

        // Create super admin user
        $superAdminUser = User::firstOrCreate(
            ['email' => 'admin@shop.test'],
            [
                'name' => 'Super Admin',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );
        $superAdminUser->syncRoles(['super_admin']);

        // Create categories
        $categories = [
            ['name' => 'Electronics', 'slug' => 'electronics', 'icon' => 'phone_iphone', 'color' => '#6366F1', 'sort_order' => 1],
            ['name' => 'Fashion', 'slug' => 'fashion', 'icon' => 'checkroom', 'color' => '#EC4899', 'sort_order' => 2],
            ['name' => 'Home & Living', 'slug' => 'home-living', 'icon' => 'home', 'color' => '#10B981', 'sort_order' => 3],
            ['name' => 'Sports', 'slug' => 'sports', 'icon' => 'sports_basketball', 'color' => '#F59E0B', 'sort_order' => 4],
            ['name' => 'Books', 'slug' => 'books', 'icon' => 'book', 'color' => '#8B5CF6', 'sort_order' => 5],
            ['name' => 'Beauty', 'slug' => 'beauty', 'icon' => 'spa', 'color' => '#F472B6', 'sort_order' => 6],
        ];

        foreach ($categories as $cat) {
            Category::firstOrCreate(['slug' => $cat['slug']], $cat);
        }

        // Create sample products
        $products = [
            ['name' => 'Wireless Headphones Pro', 'price' => 99.99, 'original_price' => 149.99, 'category' => 'electronics', 'stock' => 50, 'rating' => 4.5, 'reviews_count' => 234, 'is_featured' => true],
            ['name' => 'Smart Watch Ultra', 'price' => 199.99, 'original_price' => null, 'category' => 'electronics', 'stock' => 25, 'rating' => 4.8, 'reviews_count' => 567, 'is_featured' => true],
            ['name' => 'Premium Running Shoes', 'price' => 129.99, 'original_price' => 159.99, 'category' => 'sports', 'stock' => 100, 'rating' => 4.3, 'reviews_count' => 189, 'is_featured' => false],
            ['name' => 'Travel Backpack XL', 'price' => 79.99, 'original_price' => null, 'category' => 'fashion', 'stock' => 75, 'rating' => 4.6, 'reviews_count' => 342, 'is_featured' => true],
            ['name' => 'Designer Sunglasses', 'price' => 59.99, 'original_price' => 89.99, 'category' => 'fashion', 'stock' => 30, 'rating' => 4.2, 'reviews_count' => 156, 'is_featured' => false],
            ['name' => 'Bluetooth Speaker', 'price' => 49.99, 'original_price' => 69.99, 'category' => 'electronics', 'stock' => 80, 'rating' => 4.4, 'reviews_count' => 287, 'is_featured' => false],
            ['name' => 'Yoga Mat Premium', 'price' => 39.99, 'original_price' => null, 'category' => 'sports', 'stock' => 120, 'rating' => 4.7, 'reviews_count' => 423, 'is_featured' => false],
            ['name' => 'Coffee Table Book Set', 'price' => 34.99, 'original_price' => 49.99, 'category' => 'books', 'stock' => 45, 'rating' => 4.1, 'reviews_count' => 89, 'is_featured' => false],
        ];

        foreach ($products as $prod) {
            $category = Category::where('slug', $prod['category'])->first();
            unset($prod['category']);
            
            Product::firstOrCreate(
                ['name' => $prod['name']],
                array_merge($prod, [
                    'slug' => \Illuminate\Support\Str::slug($prod['name']),
                    'category_id' => $category?->id,
                    'description' => 'High-quality ' . strtolower($prod['name']) . ' perfect for everyday use.',
                    'is_active' => true,
                    'images' => ['https://picsum.photos/400/400?random=' . rand(1, 100)],
                ])
            );
        }
    }
}
