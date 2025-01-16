namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Sermon;
use App\Models\Event;
use App\Models\User;
use App\Models\Activity;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        // Gather statistics
        $stats = [
            'members_count' => User::count(),
            'new_members_count' => User::whereMonth('created_at', Carbon::now()->month)->count(),
            'events_count' => Event::count(),
            'upcoming_events_count' => Event::where('status', 'upcoming')->count(),
            'sermons_count' => Sermon::count(),
            'total_donations' => 0, // Implement when donation model is ready
        ];

        // Get recent activities
        $recentActivities = Activity::with('causer')
            ->latest()
            ->take(10)
            ->get()
            ->map(function ($activity) {
                return [
                    'icon' => $this->getActivityIcon($activity->description),
                    'description' => $activity->description,
                    'created_at' => $activity->created_at,
                ];
            });

        // Prepare chart data
        $chartData = $this->getEngagementChartData();

        return view('admin.dashboard.index', compact('stats', 'recentActivities', 'chartData'));
    }

    private function getActivityIcon($description)
    {
        return match (true) {
            str_contains($description, 'sermon') => 'fas fa-microphone',
            str_contains($description, 'event') => 'fas fa-calendar',
            str_contains($description, 'user') => 'fas fa-user',
            default => 'fas fa-info-circle',
        };
    }

    private function getEngagementChartData()
    {
        $days = collect(range(6, 0))->map(function ($day) {
            return Carbon::now()->subDays($day)->format('Y-m-d');
        });

        return [
            'labels' => $days->map(fn ($day) => Carbon::parse($day)->format('D')),
            'data' => $days->map(function ($day) {
                return Activity::whereDate('created_at', $day)->count();
            }),
        ];
    }
} 