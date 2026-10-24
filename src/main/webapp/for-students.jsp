<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MyPad for Students — Group Study & Lecture Notes</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mypad.css">
    <style>
        .student-container {
            max-width: 860px;
            margin: 0 auto;
            padding: 4rem 1.25rem;
        }
        .student-card {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 1.5rem;
            margin: 1.25rem 0;
            box-shadow: var(--shadow-sm);
        }
        .student-card h3 {
            font-size: 1.15rem;
            margin-bottom: 0.5rem;
        }
        .student-card p {
            color: var(--text-secondary);
            font-size: 0.9rem;
            line-height: 1.6;
        }
    </style>
</head>
<body>

    <%@ include file="includes/navbar.jsp" %>

    <main class="main-wrapper">
        <div class="student-container">
            <h1 class="hero-title" style="text-align: left; font-size: 2.25rem;">For Students & Study Groups</h1>
            <p class="hero-desc" style="text-align: left; max-width: 100%; margin-bottom: 2rem;">
                Stay synchronized across assignments, lab experiments, and shared exam preparations.
            </p>

            <div class="student-card">
                <h3>Semester Organization with Slashes</h3>
                <p>
                    Structure all your courses by semester and subject: <code>/sem5/dbms/unit1</code> and <code>/sem5/networks/lab</code>. Easily browse all units in the sidebar tree.
                </p>
            </div>

            <div class="student-card">
                <h3>Instant Collaboration in Class</h3>
                <p>
                    No need to collect email addresses or wait for share invites. Just tell your study partner the URL name or send it in group chat to take notes together in real-time.
                </p>
            </div>

            <div class="student-card">
                <h3>Offline Archival</h3>
                <p>
                    Download markdown (.md) copies of all your notes before exams with one click and open them in Obsidian, Notion, or print them directly.
                </p>
            </div>

            <div style="margin-top: 2rem;">
                <a href="<%= request.getContextPath() %>/pad.jsp?path=/college/study-group" class="btn btn-primary">
                    Create Study Pad &rarr;
                </a>
            </div>
        </div>
    </main>

    <%@ include file="includes/footer.jsp" %>

</body>
</html>
