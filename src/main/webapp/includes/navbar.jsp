<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String navUser = (String) session.getAttribute("username");
    String navContext = request.getContextPath();
%>
<header class="navbar">
    <div class="nav-container">
        <!-- Brand -->
        <a href="<%= navContext %>/" class="brand-link" aria-label="MyPad Home">
            <div class="logo-box"><span>M</span></div>
            <span>MyPad</span>
            <span class="version-badge">v1.0</span>
        </a>

        <!-- Desktop Navigation Links -->
        <nav class="nav-links" aria-label="Main Navigation">
            <a href="<%= navContext %>/online-notepad.jsp" class="nav-link">Online Notepad</a>
            <a href="<%= navContext %>/features.jsp" class="nav-link">Features</a>
            <a href="<%= navContext %>/how-it-works.jsp" class="nav-link">How it works</a>
            <a href="<%= navContext %>/use-cases.jsp" class="nav-link">Use Cases</a>
        </nav>

        <!-- Right Side Controls -->
        <div class="nav-actions">
            <!-- Theme Toggle Button -->
            <button id="themeToggleBtn" class="btn-icon" aria-label="Toggle Theme" title="Toggle Light/Dark Theme">
                <svg id="themeIconSun" style="width: 1rem; height: 1rem; display: none;" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
                <svg id="themeIconMoon" style="width: 1rem; height: 1rem;" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                </svg>
            </button>

            <!-- Authentication State -->
            <% if (navUser != null && !navUser.trim().isEmpty()) { %>
                <a href="<%= navContext %>/dashboard.jsp" class="btn btn-secondary btn-sm" title="Go to your dashboard">
                    <span style="font-family: var(--font-mono); font-size: 0.8rem; font-weight: 600;">@<%= navUser %></span>
                </a>
                <button onclick="handleLogout()" class="btn btn-secondary btn-sm" title="Sign out">
                    Logout
                </button>
            <% } else { %>
                <a href="<%= navContext %>/login.jsp" class="btn btn-primary btn-sm">
                    Sign In
                </a>
            <% } %>
        </div>
    </div>
</header>

<script>
    // Theme toggle logic with localStorage persistence
    (function() {
        const savedTheme = localStorage.getItem('mypad-theme') || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
        if (savedTheme === 'dark') {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
        updateThemeIcons();

        const btn = document.getElementById('themeToggleBtn');
        if (btn) {
            btn.addEventListener('click', function() {
                const isDark = document.documentElement.classList.toggle('dark');
                localStorage.setItem('mypad-theme', isDark ? 'dark' : 'light');
                updateThemeIcons();
            });
        }

        function updateThemeIcons() {
            const isDark = document.documentElement.classList.contains('dark');
            const sun = document.getElementById('themeIconSun');
            const moon = document.getElementById('themeIconMoon');
            if (sun && moon) {
                sun.style.display = isDark ? 'block' : 'none';
                moon.style.display = isDark ? 'none' : 'block';
            }
        }
    })();

    async function handleLogout() {
        try {
            await fetch('<%= navContext %>/api/auth/logout.jsp', { method: 'POST' });
            window.location.href = '<%= navContext %>/';
        } catch (e) {
            window.location.reload();
        }
    }
</script>
