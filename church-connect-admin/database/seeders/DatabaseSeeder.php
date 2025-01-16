namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Sermon;
use App\Models\Event;
use App\Models\Activity;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // Create admin user
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'password' => bcrypt('password'),
        ]);

        // Create test sermons
        Sermon::create([
            'title' => 'Sunday Service',
            'preacher' => 'Pastor John',
            'description' => 'A powerful message about faith',
            'audio_url' => 'https://example.com/sermon1.mp3',
            'sermon_date' => now(),
        ]);

        // Create test events
        Event::create([
            'title' => 'Youth Conference',
            'description' => 'Annual youth gathering',
            'start_date' => now()->addDays(5),
            'location' => 'Main Hall',
            'status' => 'upcoming'
        ]);

        // Create test activities
        Activity::create([
            'description' => 'New sermon was uploaded',
            'causer_type' => User::class,
            'causer_id' => 1,
            'subject_type' => Sermon::class,
            'subject_id' => 1,
        ]);
    }
} 