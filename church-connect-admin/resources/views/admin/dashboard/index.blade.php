@extends('admin.layout')

@section('content')
<div class="container-fluid">
    <!-- Analytics Overview -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="card bg-primary text-white">
                <div class="card-body">
                    <h6 class="card-title">Total Members</h6>
                    <h2>{{ $stats['members_count'] }}</h2>
                    <p class="mb-0"><small>+{{ $stats['new_members_count'] }} this month</small></p>
                </div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="card bg-success text-white">
                <div class="card-body">
                    <h6 class="card-title">Total Events</h6>
                    <h2>{{ $stats['events_count'] }}</h2>
                    <p class="mb-0"><small>{{ $stats['upcoming_events_count'] }} upcoming</small></p>
                </div>
            </div>
        </div>
        
        <!-- Add more stat cards -->
    </div>

    <!-- Charts Row -->
    <div class="row mb-4">
        <div class="col-md-8">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Engagement Trends</h5>
                    <canvas id="engagementChart"></canvas>
                </div>
            </div>
        </div>
        
        <div class="col-md-4">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Recent Activity</h5>
                    <div class="activity-feed">
                        @foreach($recentActivities as $activity)
                            <div class="activity-item">
                                <i class="{{ $activity->icon }}"></i>
                                <span>{{ $activity->description }}</span>
                                <small>{{ $activity->created_at->diffForHumans() }}</small>
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Actions -->
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Quick Actions</h5>
                    <div class="btn-group">
                        <a href="{{ route('admin.sermons.create') }}" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Add Sermon
                        </a>
                        <a href="{{ route('admin.events.create') }}" class="btn btn-success">
                            <i class="fas fa-calendar-plus"></i> Create Event
                        </a>
                        <!-- Add more quick action buttons -->
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script>
    // Initialize charts
    const ctx = document.getElementById('engagementChart').getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: {!! json_encode($chartData['labels']) !!},
            datasets: [{
                label: 'User Engagement',
                data: {!! json_encode($chartData['data']) !!},
                borderColor: 'rgb(75, 192, 192)',
                tension: 0.1
            }]
        },
        options: {
            responsive: true
        }
    });
</script>
@endpush
@endsection 