<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>How It Works — MyPad</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mypad.css">
    <style>
        .guide-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 4rem 1.25rem;
        }
        .step-card {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            padding: 1.75rem 2rem;
            margin-bottom: 1.5rem;
            box-shadow: var(--shadow-sm);
            display: flex;
            gap: 1.5rem;
            align-items: flex-start;
        }
        .step-num {
            width: 2.25rem;
            height: 2.25rem;
            border-radius: 50%;
            background: var(--accent);
            color: var(--accent-text);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 0.95rem;
            flex-shrink: 0;
        }
        .step-body h3 {
            font-size: 1.15rem;
            font-weight: 600;
            margin-bottom: 0.4rem;
        }
        .step-body p {
            font-size: 0.9rem;
            color: var(--text-secondary);
            line-height: 1.6;
        }
    </style>
</head>
<body>

    <%@ include file="includes/navbar.jsp" %>

    <main class="main-wrapper">
        <div class="guide-container">
            <div style="text-align: center; margin-bottom: 3rem;">
                <span style="font-family: var(--font-mono); font-size: 0.8rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase;">Zero Complexity</span>
                <h1 class="hero-title" style="font-size: 2.5rem; margin-top: 0.5rem;">How MyPad Works</h1>
                <p class="hero-desc" style="margin: 0.75rem auto 0;">Start collaborating in three dead-simple steps.</p>
            </div>

            <div class="step-card">
                <div class="step-num">1</div>
                <div class="step-body">
                    <h3>Type Any URL Path</h3>
                    <p>Enter any custom pad name on the homepage or append it right to the URL: <code>/pad?path=/your-topic</code>. If it doesn't exist, it is instantly initialized.</p>
                </div>
            </div>

            <div class="step-card">
                <div class="step-num">2</div>
                <div class="step-body">
                    <h3>Write & Share the Link</h3>
                    <p>Everything you write is saved automatically in real-time. Share the link with teammates, classmates, or devices — no invites or emails necessary.</p>
                </div>
            </div>

            <div class="step-card">
                <div class="step-num">3</div>
                <div class="step-body">
                    <h3>Register for Personal Pads (Optional)</h3>
                    <p>Want a private workspace? Create an account using only your email and password to claim your <code>@username</code> and manage your pads from a personal dashboard.</p>
                </div>
            </div>
        </div>
    </main>

    <%@ include file="includes/footer.jsp" %>

</body>
</html>
