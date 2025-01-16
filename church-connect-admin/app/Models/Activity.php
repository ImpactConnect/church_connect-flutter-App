namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Activity extends Model
{
    protected $fillable = [
        'description',
        'causer_type',
        'causer_id',
        'subject_type',
        'subject_id',
        'properties'
    ];

    protected $casts = [
        'properties' => 'array'
    ];

    public function causer()
    {
        return $this->morphTo();
    }

    public function subject()
    {
        return $this->morphTo();
    }
} 