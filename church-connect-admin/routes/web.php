use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\SermonController;
use App\Http\Controllers\Admin\EventController;
use App\Http\Controllers\Admin\VideoController;
use App\Http\Controllers\Admin\BlogController;
use App\Http\Controllers\Admin\HymnalController;
use App\Http\Controllers\Admin\GalleryController;
use App\Http\Controllers\Admin\DonationController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\NotificationController;
use App\Http\Controllers\Admin\SettingController;

Route::get('/', function () {
    return redirect()->route('admin.dashboard');
});

Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    
    // Resource routes
    Route::resources([
        'sermons' => SermonController::class,
        'events' => EventController::class,
        'videos' => VideoController::class,
        'blog' => BlogController::class,
        'hymnal' => HymnalController::class,
        'gallery' => GalleryController::class,
        'donations' => DonationController::class,
        'users' => UserController::class,
        'notifications' => NotificationController::class,
        'settings' => SettingController::class,
    ]);
}); 