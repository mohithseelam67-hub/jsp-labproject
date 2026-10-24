<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String currentUsername = (String) session.getAttribute("username");
    String initialPath = request.getParameter("path");
    if (initialPath == null || initialPath.trim().isEmpty()) {
        initialPath = "/notes";
    }
    if (!initialPath.startsWith("/")) {
        initialPath = "/" + initialPath;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0">
    <title>MyPad — <%= initialPath %></title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mypad.css">
    <style>
        .editor-layout {
            display: flex;
            flex-direction: column;
            height: calc(100vh - 3.5rem);
            overflow: hidden;
            background: var(--bg-page);
        }

        /* PAD TOOLBAR */
        .pad-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            padding: 0.5rem 1.25rem;
            border-bottom: 1px solid var(--border-color);
            background: var(--bg-page);
            gap: 0.75rem;
            min-height: 3rem;
            user-select: none;
        }

        .breadcrumbs-bar {
            display: flex;
            align-items: center;
            gap: 0.35rem;
            font-family: var(--font-mono);
            font-size: 0.85rem;
            overflow-x: auto;
            white-space: nowrap;
        }

        .breadcrumb-item {
            color: var(--text-secondary);
            transition: color 0.15s ease;
            cursor: pointer;
        }

        .breadcrumb-item:hover {
            color: var(--text-primary);
        }

        .breadcrumb-item.active {
            color: var(--text-primary);
            font-weight: 600;
        }

        .breadcrumb-separator {
            color: var(--text-muted);
            font-size: 0.75rem;
        }

        .pad-meta-group {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            font-size: 0.75rem;
        }

        .save-badge {
            font-size: 0.75rem;
            font-family: var(--font-mono);
            padding: 0.2rem 0.5rem;
            border-radius: 4px;
            color: var(--text-secondary);
            background: var(--btn-secondary-bg);
            border: 1px solid var(--border-color);
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
        }

        .save-badge.saving {
            color: #d97706;
            background: #fef3c7;
            border-color: #fde68a;
        }

        .save-badge.conflict {
            color: var(--danger);
            background: var(--danger-bg);
            border-color: var(--danger-border);
        }

        .save-badge.readonly {
            color: #6366f1;
            background: rgba(99, 102, 241, 0.1);
            border-color: rgba(99, 102, 241, 0.25);
        }

        .save-badge.owner {
            color: #10b981;
            background: rgba(16, 185, 129, 0.1);
            border-color: rgba(16, 185, 129, 0.25);
        }

        .pad-textarea.readonly-mode {
            cursor: default;
        }

        .readonly-banner {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
            padding: 0.45rem 1.25rem;
            background: rgba(99, 102, 241, 0.08);
            border-bottom: 1px solid rgba(99, 102, 241, 0.2);
            color: #6366f1;
            font-size: 0.8rem;
        }

        [data-theme="dark"] .readonly-banner {
            background: rgba(99, 102, 241, 0.15);
            border-bottom-color: rgba(99, 102, 241, 0.3);
            color: #a5b4fc;
        }

        .editor-actions {
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }

        /* FIND & REPLACE BAR */
        .find-bar {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.4rem 1.25rem;
            border-bottom: 1px solid var(--border-color);
            background: var(--bg-surface);
            font-size: 0.8rem;
        }

        .find-bar input {
            padding: 0.3rem 0.6rem;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            background: var(--bg-card);
            color: var(--text-primary);
            font-family: var(--font-mono);
            font-size: 0.8rem;
            outline: none;
        }

        /* MAIN EDITOR WORKSPACE */
        .editor-workspace {
            flex: 1;
            display: flex;
            position: relative;
            overflow: hidden;
        }

        .editor-main-area {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            position: relative;
        }

        .pad-textarea {
            width: 100%;
            height: 100%;
            border: none;
            outline: none;
            padding: 1.5rem 2rem;
            font-size: 1rem;
            line-height: 1.7;
            background: transparent;
            color: var(--text-primary);
            resize: none;
            overflow-y: auto;
            tab-size: 4;
            transition: font-family 0.15s ease;
        }

        .font-mono-mode {
            font-family: var(--font-mono) !important;
        }

        .font-sans-mode {
            font-family: var(--font-sans) !important;
        }

        /* SIDEBAR (CHILDREN / TREE) */
        .pad-sidebar {
            width: 280px;
            border-left: 1px solid var(--border-color);
            background: var(--bg-surface);
            display: flex;
            flex-direction: column;
            transition: margin-right 0.2s ease;
            overflow: hidden;
        }

        .pad-sidebar.closed {
            display: none;
        }

        .sidebar-header {
            padding: 0.85rem 1rem;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .sidebar-content {
            flex: 1;
            overflow-y: auto;
            padding: 0.75rem;
            display: flex;
            flex-direction: column;
            gap: 0.35rem;
        }

        .tree-item {
            padding: 0.45rem 0.65rem;
            border-radius: 6px;
            font-family: var(--font-mono);
            font-size: 0.8rem;
            color: var(--text-secondary);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: all 0.15s ease;
        }

        .tree-item:hover {
            background: var(--btn-secondary-bg);
            color: var(--text-primary);
        }

        .tree-badge {
            font-size: 0.68rem;
            padding: 0.1rem 0.35rem;
            border-radius: 4px;
            background: var(--border-color);
            color: var(--text-muted);
        }
    </style>
</head>
<body data-context-path="<%= request.getContextPath() %>" data-path="<%= initialPath %>" data-username="<%= currentUsername != null ? currentUsername : "" %>">

    <%@ include file="includes/navbar.jsp" %>

    <div class="editor-layout" id="editorLayout">
        <!-- Pad Header Toolbar -->
        <div class="pad-header">
            <!-- Breadcrumbs -->
            <div class="breadcrumbs-bar" id="breadcrumbsBar">
                <span class="breadcrumb-item" onclick="navigateTo('/')">root</span>
            </div>

            <!-- Metadata & Save Status -->
            <div class="pad-meta-group">
                <span id="ownerBadge" class="save-badge owner" style="display: none;">👑 Owner (Read-only for others)</span>
                <span id="saveStatus" class="save-badge">Ready</span>
                <span id="wordCountBadge" class="save-badge" style="background: transparent; border: none; color: var(--text-muted);">
                    0 words &bull; 0 chars
                </span>
            </div>

            <!-- Actions Toolbar -->
            <div class="editor-actions">
                <button id="btnToggleFont" class="btn btn-secondary btn-sm" onclick="toggleFontMode()" title="Toggle Sans / Monospace font">
                    <span id="fontModeLabel">Mono</span>
                </button>
                <button id="btnFind" class="btn btn-secondary btn-sm" onclick="toggleFindBar()" title="Find & Replace (Ctrl+F)">
                    Find
                </button>
                <button id="btnCopyLink" class="btn btn-secondary btn-sm" onclick="copyPadLink()" title="Copy Link to Clipboard">
                    Share
                </button>
                <button id="btnDownload" class="btn btn-secondary btn-sm" onclick="downloadPad()" title="Export Note">
                    Export
                </button>
                <button id="btnToggleSidebar" class="btn btn-secondary btn-sm" onclick="toggleSidebar()" title="Toggle Nested Tree">
                    Tree
                </button>
                <button id="btnDelete" class="btn btn-secondary btn-sm" style="color: var(--danger);" onclick="deleteCurrentPad()" title="Delete Pad">
                    &times;
                </button>
            </div>
        </div>

        <!-- Read-Only Notice Banner -->
        <div id="readOnlyBanner" class="readonly-banner" style="display: none;">
            <div style="display: flex; align-items: center; gap: 0.5rem;">
                <span style="font-size: 0.9rem;">🔒</span>
                <span>This pad is published by <strong id="readOnlyAuthor">@author</strong> in <strong>Read-Only</strong> mode. Edits are restricted to the author.</span>
            </div>
            <button class="btn btn-secondary btn-sm" onclick="copyPadLink()" style="font-size: 0.75rem; padding: 0.2rem 0.6rem;">Copy Link</button>
        </div>

        <!-- Find & Replace Bar -->
        <div id="findBar" class="find-bar" style="display: none;">
            <input type="text" id="findInput" placeholder="Find text..." oninput="handleFind()" />
            <input type="text" id="replaceInput" placeholder="Replace with..." />
            <button class="btn btn-secondary btn-sm" onclick="replaceNext()">Replace</button>
            <button class="btn btn-secondary btn-sm" onclick="replaceAll()">Replace All</button>
            <button class="btn btn-secondary btn-sm" onclick="toggleFindBar()" style="margin-left: auto;">&times; Close</button>
        </div>

        <!-- Editor Workspace -->
        <div class="editor-workspace">
            <!-- Textarea Area -->
            <div class="editor-main-area">
                <textarea 
                    id="padEditor" 
                    class="pad-textarea font-mono-mode" 
                    placeholder="Start typing your thoughts, notes, code, or snippets... Auto-saves instantly." 
                    spellcheck="false"
                ></textarea>
            </div>

            <!-- Children / Sub-pads Sidebar -->
            <aside id="padSidebar" class="pad-sidebar closed">
                <div class="sidebar-header">
                    <span>Nested Pads</span>
                    <button class="btn btn-secondary btn-sm" onclick="createSubPad()">+ New</button>
                </div>
                <div id="childrenList" class="sidebar-content">
                    <div style="font-size: 0.75rem; color: var(--text-muted); text-align: center; padding: 1rem;">
                        Loading nested pads...
                    </div>
                </div>
            </aside>
        </div>
    </div>

    <script>
        const CTX = document.body.dataset.contextPath || '';
        let currentPath = document.body.dataset.path || '/notes';
        let currentVersion = 1;
        let isMono = true;
        let saveTimer = null;
        let isSaving = false;
        let hasPendingChanges = false;
        let isReadOnly = false;
        let isOwner = false;

        const editorEl = document.getElementById('padEditor');
        const saveStatusEl = document.getElementById('saveStatus');
        const wordCountEl = document.getElementById('wordCountBadge');

        // Initial Load
        window.addEventListener('DOMContentLoaded', () => {
            updateBreadcrumbs(currentPath);
            loadPad(currentPath);

            // Tab Key Interception in Textarea
            editorEl.addEventListener('keydown', (e) => {
                if (isReadOnly) {
                    if (e.key === 'Tab') {
                        e.preventDefault();
                    } else if ((e.ctrlKey || e.metaKey) && e.key === 's') {
                        e.preventDefault();
                        setStatus('🔒 Read-only', 'readonly');
                    }
                    return;
                }

                if (e.key === 'Tab') {
                    e.preventDefault();
                    const start = editorEl.selectionStart;
                    const end = editorEl.selectionEnd;
                    editorEl.value = editorEl.value.substring(0, start) + '  ' + editorEl.value.substring(end);
                    editorEl.selectionStart = editorEl.selectionEnd = start + 2;
                    triggerAutoSave();
                } else if ((e.ctrlKey || e.metaKey) && e.key === 's') {
                    e.preventDefault();
                    savePadNow();
                } else if ((e.ctrlKey || e.metaKey) && e.key === 'f') {
                    e.preventDefault();
                    toggleFindBar();
                }
            });

            editorEl.addEventListener('input', () => {
                updateStats();
                if (!isReadOnly) {
                    triggerAutoSave();
                }
            });
        });

        function updateBreadcrumbs(path) {
            const bar = document.getElementById('breadcrumbsBar');
            bar.innerHTML = '';

            const segments = path.split('/').filter(Boolean);
            let cumulative = '';

            // Root
            const rootItem = document.createElement('span');
            rootItem.className = 'breadcrumb-item';
            rootItem.textContent = 'home';
            rootItem.onclick = () => window.location.href = CTX + '/';
            bar.appendChild(rootItem);

            segments.forEach((seg, idx) => {
                const sep = document.createElement('span');
                sep.className = 'breadcrumb-separator';
                sep.textContent = '/';
                bar.appendChild(sep);

                cumulative += '/' + seg;
                const pathForLink = cumulative;

                const item = document.createElement('span');
                item.className = 'breadcrumb-item' + (idx === segments.length - 1 ? ' active' : '');
                item.textContent = seg;
                if (idx < segments.length - 1) {
                    item.onclick = () => {
                        window.location.href = CTX + '/pad.jsp?path=' + encodeURIComponent(pathForLink);
                    };
                }
                bar.appendChild(item);
            });
        }

        function updateStats() {
            const text = editorEl.value;
            const chars = text.length;
            const words = text.trim() ? text.trim().split(/\s+/).length : 0;
            wordCountEl.textContent = words + ' words • ' + chars.toLocaleString() + ' chars';
        }

        function setStatus(text, type) {
            saveStatusEl.className = 'save-badge ' + (type || '');
            saveStatusEl.textContent = text;
        }

        async function loadPad(path) {
            try {
                setStatus('Loading...', 'saving');
                const res = await fetch(CTX + '/api/pad.jsp?path=' + encodeURIComponent(path));
                const data = await res.json();
                if (!res.ok) throw new Error(data.error || 'Failed to load pad');

                currentVersion = data.version || 1;
                editorEl.value = data.content || '';
                updateStats();
                document.title = 'MyPad — ' + data.path;

                isReadOnly = !!data.isReadOnly;
                isOwner = !!data.isOwner;

                const readOnlyBanner = document.getElementById('readOnlyBanner');
                const ownerBadge = document.getElementById('ownerBadge');
                const btnDelete = document.getElementById('btnDelete');

                if (isReadOnly) {
                    editorEl.readOnly = true;
                    editorEl.classList.add('readonly-mode');
                    setStatus('🔒 Read-only', 'readonly');
                    if (readOnlyBanner) {
                        readOnlyBanner.style.display = 'flex';
                        const authorEl = document.getElementById('readOnlyAuthor');
                        if (authorEl) {
                            authorEl.textContent = data.ownerUsername ? '@' + data.ownerUsername : 'the author';
                        }
                    }
                    if (btnDelete) btnDelete.style.display = 'none';
                    if (ownerBadge) ownerBadge.style.display = 'none';
                } else {
                    editorEl.readOnly = false;
                    editorEl.classList.remove('readonly-mode');
                    if (readOnlyBanner) readOnlyBanner.style.display = 'none';
                    if (btnDelete) btnDelete.style.display = 'inline-flex';
                    if (ownerBadge) {
                        if (isOwner && (data.visibility === 'read-only' || data.ownerUsername)) {
                            ownerBadge.style.display = 'inline-flex';
                        } else {
                            ownerBadge.style.display = 'none';
                        }
                    }
                    setStatus('Saved');
                }

                loadChildren(path);
            } catch (err) {
                setStatus('Error: ' + err.message, 'conflict');
            }
        }

        function triggerAutoSave() {
            if (isReadOnly) return;
            hasPendingChanges = true;
            setStatus('Typing...', 'saving');
            clearTimeout(saveTimer);
            saveTimer = setTimeout(() => {
                savePadNow();
            }, 1400);
        }

        async function savePadNow() {
            if (isReadOnly || isSaving) return;
            isSaving = true;
            clearTimeout(saveTimer);
            setStatus('Saving...', 'saving');

            try {
                const res = await fetch(CTX + '/api/save.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json;charset=UTF-8' },
                    body: JSON.stringify({
                        path: currentPath,
                        content: editorEl.value,
                        version: currentVersion
                    })
                });

                const data = await res.json();
                if (res.status === 409) {
                    setStatus('Version conflict!', 'conflict');
                    if (confirm('Another session has updated this pad. Reload latest version? (Your unsaved edits will be replaced)')) {
                        loadPad(currentPath);
                    }
                    isSaving = false;
                    return;
                }

                if (!res.ok || !data.success) {
                    throw new Error(data.error || 'Save failed');
                }

                currentVersion = data.version;
                setStatus('Saved');
                hasPendingChanges = false;
            } catch (err) {
                setStatus('Save failed: ' + err.message, 'conflict');
            } finally {
                isSaving = false;
            }
        }

        async function loadChildren(parentPath) {
            const listEl = document.getElementById('childrenList');
            try {
                const res = await fetch(CTX + '/api/children.jsp?path=' + encodeURIComponent(parentPath));
                const data = await res.json();
                if (!res.ok) return;

                listEl.innerHTML = '';
                if (!data.children || data.children.length === 0) {
                    listEl.innerHTML = '<div style="font-size: 0.75rem; color: var(--text-muted); text-align: center; padding: 1.5rem 0.5rem;">No nested pads under this path yet.</div>';
                    return;
                }

                data.children.forEach(child => {
                    const item = document.createElement('div');
                    item.className = 'tree-item';
                    item.onclick = () => {
                        window.location.href = CTX + '/pad.jsp?path=' + encodeURIComponent(child.path);
                    };
                    item.innerHTML = 
                        '<span>' + child.name + '</span>' +
                        '<span class="tree-badge">' + (child.isPad ? 'v' + child.version : 'dir') + '</span>';
                    listEl.appendChild(item);
                });
            } catch (e) {
                listEl.innerHTML = '<div style="font-size: 0.75rem; color: var(--danger); text-align: center;">Error loading tree</div>';
            }
        }

        function createSubPad() {
            const name = prompt('Enter name for the new sub-pad:');
            if (name && name.trim()) {
                const clean = name.trim().replace(/^\/+/, '');
                const newPath = (currentPath === '/' ? '' : currentPath) + '/' + clean;
                window.location.href = CTX + '/pad.jsp?path=' + encodeURIComponent(newPath);
            }
        }

        function toggleFontMode() {
            isMono = !isMono;
            editorEl.className = 'pad-textarea ' + (isMono ? 'font-mono-mode' : 'font-sans-mode');
            document.getElementById('fontModeLabel').textContent = isMono ? 'Mono' : 'Sans';
        }

        function toggleSidebar() {
            const sidebar = document.getElementById('padSidebar');
            sidebar.classList.toggle('closed');
        }

        function toggleFindBar() {
            const bar = document.getElementById('findBar');
            const isHidden = bar.style.display === 'none';
            bar.style.display = isHidden ? 'flex' : 'none';
            if (isHidden) {
                document.getElementById('findInput').focus();
            }
        }

        function handleFind() {
            const term = document.getElementById('findInput').value;
            if (!term) return;
            const text = editorEl.value;
            const idx = text.indexOf(term, editorEl.selectionStart);
            if (idx !== -1) {
                editorEl.focus();
                editorEl.setSelectionRange(idx, idx + term.length);
            }
        }

        function replaceNext() {
            const findTerm = document.getElementById('findInput').value;
            const replaceTerm = document.getElementById('replaceInput').value;
            if (!findTerm) return;

            const text = editorEl.value;
            const start = editorEl.selectionStart;
            const end = editorEl.selectionEnd;

            if (text.substring(start, end) === findTerm) {
                editorEl.setRangeText(replaceTerm, start, end, 'end');
                triggerAutoSave();
            }
            handleFind();
        }

        function replaceAll() {
            const findTerm = document.getElementById('findInput').value;
            const replaceTerm = document.getElementById('replaceInput').value;
            if (!findTerm) return;

            editorEl.value = editorEl.value.replaceAll(findTerm, replaceTerm);
            updateStats();
            triggerAutoSave();
        }

        function copyPadLink() {
            navigator.clipboard.writeText(window.location.href);
            const btn = document.getElementById('btnCopyLink');
            const original = btn.textContent;
            btn.textContent = 'Copied!';
            setTimeout(() => btn.textContent = original, 1500);
        }

        function downloadPad() {
            const blob = new Blob([editorEl.value], { type: 'text/markdown;charset=utf-8' });
            const a = document.createElement('a');
            const filename = currentPath.split('/').filter(Boolean).pop() || 'pad';
            a.href = URL.createObjectURL(blob);
            a.download = filename + '.md';
            a.click();
        }

        async function deleteCurrentPad() {
            if (!confirm('Are you sure you want to permanently delete this pad (' + currentPath + ')?')) {
                return;
            }
            try {
                const res = await fetch(CTX + '/api/pads/delete.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ path: currentPath })
                });
                const data = await res.json();
                if (!res.ok) throw new Error(data.error || 'Failed to delete');
                alert('Pad deleted.');
                window.location.href = CTX + '/';
            } catch (err) {
                alert('Delete error: ' + err.message);
            }
        }
    </script>
</body>
</html>
