namespace App\Traits;

use App\Models\Activity;

trait LogsActivity
{
    public static function bootLogsActivity()
    {
        static::created(function ($model) {
            $model->logActivity('created');
        });

        static::updated(function ($model) {
            $model->logActivity('updated');
        });

        static::deleted(function ($model) {
            $model->logActivity('deleted');
        });
    }

    protected function logActivity($action)
    {
        Activity::create([
            'description' => "{$this->getActivityDescription()} was {$action}",
            'causer_type' => auth()->user() ? get_class(auth()->user()) : null,
            'causer_id' => auth()->id(),
            'subject_type' => get_class($this),
            'subject_id' => $this->id,
            'properties' => $this->getActivityProperties()
        ]);
    }

    protected function getActivityDescription()
    {
        return class_basename($this);
    }

    protected function getActivityProperties()
    {
        return $this->toArray();
    }
} 