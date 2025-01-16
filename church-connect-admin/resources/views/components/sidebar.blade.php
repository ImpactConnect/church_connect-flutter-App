<div class="sidebar bg-dark text-white" id="sidebar">
    <div class="sidebar-header p-3">
        <img src="{{ asset('images/logo.png') }}" alt="Logo" class="logo">
        <h5 class="mt-2">Church Connect</h5>
    </div>

    <ul class="nav flex-column">
        <li class="nav-item">
            <a href="{{ route('admin.dashboard') }}" class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>
        </li>
        
        <li class="nav-item">
            <a href="{{ route('admin.sermons.index') }}" class="nav-link {{ request()->routeIs('admin.sermons.*') ? 'active' : '' }}">
                <i class="fas fa-microphone"></i> Audio Library
            </a>
        </li>

        <li class="nav-item">
            <a href="{{ route('admin.videos.index') }}" class="nav-link {{ request()->routeIs('admin.videos.*') ? 'active' : '' }}">
                <i class="fas fa-video"></i> Video Library
            </a>
        </li>

        <li class="nav-item">
            <a href="{{ route('admin.blog.index') }}" class="nav-link {{ request()->routeIs('admin.blog.*') ? 'active' : '' }}">
                <i class="fas fa-blog"></i> Blog
            </a>
        </li>

        <li class="nav-item">
            <a href="{{ route('admin.hymnal.index') }}" class="nav-link {{ request()->routeIs('admin.hymnal.*') ? 'active' : '' }}">
                <i class="fas fa-music"></i> Hymnal
            </a>
        </li>

        <li class="nav-item">
            <a href="{{ route('admin.events.index') }}" class="nav-link {{ request()->routeIs('admin.events.*') ? 'active' : '' }}">
                <i class="fas fa-calendar"></i> Events
            </a>
        </li>

        <li class="nav-item">
            <a href="{{ route('admin.gallery.index') }}" class="nav-link {{ request()->routeIs('admin.gallery.*') ? 'active' : '' }}">
                <i class="fas fa-images"></i> Gallery
            </a>
        </li>

        <li class="nav-item">
            <a href="{{ route('admin.donations.index') }}" class="nav-link {{ request()->routeIs('admin.donations.*') ? 'active' : '' }}">
                <i class="fas fa-hand-holding-usd"></i> Donations
            </a>
        </li>

        <li class="nav-item">
            <a href="{{ route('admin.users.index') }}" class="nav-link {{ request()->routeIs('admin.users.*') ? 'active' : '' }}">
                <i class="fas fa-users"></i> Users
            </a>
        </li>

        <li class="nav-item">
            <a href="{{ route('admin.notifications.index') }}" class="nav-link {{ request()->routeIs('admin.notifications.*') ? 'active' : '' }}">
                <i class="fas fa-bell"></i> Notifications
            </a>
        </li>

        <li class="nav-item">
            <a href="{{ route('admin.settings.index') }}" class="nav-link {{ request()->routeIs('admin.settings.*') ? 'active' : '' }}">
                <i class="fas fa-cog"></i> Settings
            </a>
        </li>
    </ul>
</div> 