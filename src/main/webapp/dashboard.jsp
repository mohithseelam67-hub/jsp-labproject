<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String currentUsername = (String) session.getAttribute("username");
    if (currentUsername == null || currentUsername.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=" + request.getContextPath() + "/dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — @<%= currentUsername %> — MyPad</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mypad.css">
    <style>
        .dashboard-container {
            max-width: 1060px;
            margin: 0 auto;
            padding: 2.5rem 1.25rem;
            width: 100%;
        }
        .profile-banner {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 1.5rem 1.75rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 1rem;
            box-shadow: var(--shadow-sm);
            margin-bottom: 2rem;
        }
        .profile-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .profile-avatar {
            width: 3.5rem;
            height: 3.5rem;
            border-radius: 50%;
            background: var(--text-primary);
            color: var(--bg-page);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            font-weight: 700;
            font-family: var(--font-mono);
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }
        .stat-card {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 1.25rem 1.5rem;
            box-shadow: var(--shadow-sm);
        }
        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            letter-spacing: -0.03em;
            color: var(--text-primary);
        }
        .stat-label {
            font-size: 0.8rem;
            color: var(--text-secondary);
            margin-top: 0.25rem;
        }
        .pads-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1.25rem;
        }
        .pads-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(310px, 1fr));
            gap: 1rem;
        }
        .pad-card {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 1.25rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: all 0.15s ease;
            box-shadow: var(--shadow-sm);
        }
        .pad-card:hover {
            border-color: var(--text-secondary);
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }
        .pad-card-path {
            font-family: var(--font-mono);
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-primary);
            word-break: break-all;
        }
        .pad-card-snippet {
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin: 0.75rem 0;
            line-height: 1.5;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            min-height: 3.8rem;
        }
        .pad-card-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-top: 0.75rem;
            border-top: 1px solid var(--border-subtle);
            font-size: 0.75rem;
            color: var(--text-muted);
        }
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(4px);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 100;
            padding: 1rem;
        }
        .modal-card {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            max-width: 440px;
            width: 100%;
            padding: 1.75rem;
            box-shadow: var(--shadow-lg);
        }
    </style>
</head>
<body data-context-path="<%= request.getContextPath() %>" data-username="<%= currentUsername %>">

    <%@ include file="includes/navbar.jsp" %>

    <main class="main-wrapper">
        <div class="dashboard-container">
            <!-- Profile Banner -->
            <div class="profile-banner">
                <div class="profile-info">
                    <div class="profile-avatar">
                        <%= currentUsername.substring(0, 1).toUpperCase() %>
                    </div>
                    <div>
                        <h1 style="font-size: 1.35rem; font-weight: 700; letter-spacing: -0.02em;">
                            @<%= currentUsername %>
                        </h1>
                        <p style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 0.15rem;">
                            Account &bull; Member
                        </p>
                    </div>
                </div>
                <div style="display: flex; gap: 0.5rem;">
                    <button class="btn btn-primary" onclick="openNewPadModal()">
                        + Create New Pad
                    </button>
                    <button class="btn btn-secondary" onclick="handleLogout()">
                        Sign Out
                    </button>
                </div>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-value" id="statTotalPads">0</div>
                    <div class="stat-label">Total Saved Pads</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="statTotalWords">0</div>
                    <div class="stat-label">Total Words Written</div>
                </div>
            </div>

            <!-- Pads Section -->
            <div class="pads-header">
                <div>
                    <h2 style="font-size: 1.15rem; font-weight: 600;">Your Pads</h2>
                    <p style="font-size: 0.8rem; color: var(--text-secondary);">Manage and quick-launch your notes</p>
                </div>
                <div style="max-width: 280px; width: 100%;">
                    <input 
                        type="text" 
                        id="filterInput" 
                        class="form-control" 
                        placeholder="Filter your pads..." 
                        oninput="filterPads()"
                        style="padding: 0.45rem 0.75rem; font-size: 0.85rem;"
                    />
                </div>
            </div>

            <!-- Pads Grid / Container -->
            <div id="padsGrid" class="pads-grid">
                <div style="font-size: 0.85rem; color: var(--text-muted); padding: 2rem 0; grid-column: 1 / -1; text-align: center;">
                    Loading your pads...
                </div>
            </div>
        </div>
    </main>

    <!-- Create Pad Modal -->
    <div id="newPadModal" class="modal-overlay" style="display: none;">
        <div class="modal-card">
            <h3 style="font-size: 1.15rem; font-weight: 600; margin-bottom: 0.5rem;">Create a New Pad</h3>
            <p style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 1.25rem;">
                Pads created in your profile are published as <strong>Read-Only</strong> for other visitors and editable by you.
            </p>
            <form onsubmit="handleCreatePadSubmit(event)">
                <div class="form-group">
                    <label class="form-label" for="newPadPath">Pad Path</label>
                    <input 
                        type="text" 
                        id="newPadPath" 
                        class="form-control" 
                        placeholder="/@<%= currentUsername %>/notes" 
                        required 
                        style="font-family: var(--font-mono);"
                    />
                </div>
                <div style="display: flex; justify-content: flex-end; gap: 0.5rem; margin-top: 1.5rem;">
                    <button type="button" class="btn btn-secondary" onclick="closeNewPadModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary">Open & Save</button>
                </div>
            </form>
        </div>
    </div>

    <%@ include file="includes/footer.jsp" %>

    <script>
        const CTX = document.body.dataset.contextPath || '';
        const USERNAME = document.body.dataset.username || '';
        let allPads = [];

        async function loadUserPads() {
            try {
                const res = await fetch(CTX + '/api/pads/user.jsp');
                if (res.status === 401) {
                    window.location.href = CTX + '/login.jsp';
                    return;
                }
                const data = await res.json();
                if (!res.ok) throw new Error(data.error || 'Failed to load pads');

                allPads = data.pads || [];
                document.getElementById('statTotalPads').textContent = data.totalPads || allPads.length;
                document.getElementById('statTotalWords').textContent = Number(data.totalWords || 0).toLocaleString();

                renderPads(allPads);
            } catch (err) {
                document.getElementById('padsGrid').innerHTML = '<div style="color: var(--danger); text-align: center; padding: 2rem; grid-column: 1 / -1;">Error loading pads: ' + err.message + '</div>';
            }
        }

        function renderPads(pads) {
            const grid = document.getElementById('padsGrid');
            grid.innerHTML = '';

            if (pads.length === 0) {
                grid.innerHTML = 
                    '<div style="grid-column: 1 / -1; text-align: center; padding: 3rem 1rem; background: var(--bg-card); border: 1px dashed var(--border-color); border-radius: 12px;">' +
                        '<p style="color: var(--text-secondary); font-size: 0.95rem; margin-bottom: 0.75rem;">No pads found in your collection yet.</p>' +
                        '<button class="btn btn-primary btn-sm" onclick="openNewPadModal()">+ Create your first pad</button>' +
                    '</div>';
                return;
            }

            pads.forEach(p => {
                const card = document.createElement('div');
                card.className = 'pad-card';

                const updated = p.updatedAt ? new Date(p.updatedAt).toLocaleDateString() : 'Recently';
                const vis = (p.visibility && p.visibility !== 'public') ? p.visibility : 'read-only';
                const isReadOnly = vis === 'read-only';
                const visBadge = '<span class="version-badge" style="font-size: 0.68rem; text-transform: uppercase; ' + 
                    (isReadOnly ? 'background: rgba(99, 102, 241, 0.1); color: #6366f1; border-color: rgba(99, 102, 241, 0.25);' : '') + 
                    '">' + (isReadOnly ? '🔒 ' : '') + vis + '</span>';

                card.innerHTML = 
                    '<div>' +
                        '<div style="display: flex; align-items: center; justify-content: space-between;">' +
                            '<span class="pad-card-path">' + p.path + '</span>' +
                            visBadge +
                        '</div>' +
                        '<div class="pad-card-snippet">' + (p.snippet ? escapeHtml(p.snippet) : '<em style="color: var(--text-muted);">Empty note</em>') + '</div>' +
                    '</div>' +
                    '<div class="pad-card-footer">' +
                        '<span>' + p.wordCount + ' words &bull; ' + updated + '</span>' +
                        '<div style="display: flex; gap: 0.4rem;">' +
                            '<button class="btn btn-secondary btn-sm" onclick="openPad(\'' + p.path + '\')">Open</button>' +
                            '<button class="btn btn-secondary btn-sm" style="color: var(--danger);" title="Delete pad" onclick="deletePad(\'' + p.path + '\')">&times;</button>' +
                        '</div>' +
                    '</div>';

                grid.appendChild(card);
            });
        }

        function escapeHtml(str) {
            return str.replace(/[&<>"']/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[m]);
        }

        function filterPads() {
            const query = document.getElementById('filterInput').value.trim().toLowerCase();
            if (!query) {
                renderPads(allPads);
                return;
            }
            const filtered = allPads.filter(p => p.path.toLowerCase().includes(query) || (p.snippet && p.snippet.toLowerCase().includes(query)));
            renderPads(filtered);
        }

        function openPad(path) {
            window.location.href = CTX + '/pad.jsp?path=' + encodeURIComponent(path);
        }

        async function deletePad(path) {
            if (!confirm('Are you sure you want to permanently delete pad "' + path + '"?')) {
                return;
            }
            try {
                const res = await fetch(CTX + '/api/pads/delete.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ path: path })
                });
                const data = await res.json();
                if (!res.ok) throw new Error(data.error || 'Failed to delete');
                loadUserPads();
            } catch (err) {
                alert('Delete error: ' + err.message);
            }
        }

        function openNewPadModal() {
            document.getElementById('newPadPath').value = '/@' + USERNAME + '/note-' + Math.floor(Math.random() * 900 + 100);
            document.getElementById('newPadModal').style.display = 'flex';
            setTimeout(() => document.getElementById('newPadPath').focus(), 100);
        }

        function closeNewPadModal() {
            document.getElementById('newPadModal').style.display = 'none';
        }

        function handleCreatePadSubmit(e) {
            e.preventDefault();
            let path = document.getElementById('newPadPath').value.trim();
            if (!path.startsWith('/')) path = '/' + path;
            if (!path.startsWith('/@')) {
                path = '/@' + USERNAME + (path.startsWith('/') ? path : '/' + path);
            }
            window.location.href = CTX + '/pad.jsp?path=' + encodeURIComponent(path);
        }

        window.addEventListener('DOMContentLoaded', loadUserPads);
    </script>
</body>
</html>
