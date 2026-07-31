<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Download Dholera Real Estate App | Official Mobile & Web Portal</title>
    <meta name="description" content="Download the official Dholera Real Estate Android Mobile App or access the live web portal for Dholera SIR property listings, survey numbers, and zone plots.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-dark: #090d16;
            --bg-card: #131b2e;
            --bg-card-hover: #1a253e;
            --primary: #10b981;
            --primary-glow: rgba(16, 185, 129, 0.35);
            --primary-accent: #059669;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --border: rgba(255, 255, 255, 0.08);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Outfit', -apple-system, BlinkMacSystemFont, sans-serif;
        }

        body {
            background-color: var(--bg-dark);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: space-between;
            background-image: 
                radial-gradient(circle at 15% 20%, rgba(16, 185, 129, 0.15) 0%, transparent 40%),
                radial-gradient(circle at 85% 80%, rgba(59, 130, 246, 0.12) 0%, transparent 45%);
            overflow-x: hidden;
        }

        header {
            width: 100%;
            max-width: 1200px;
            padding: 2rem 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo-box {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            text-decoration: none;
            color: var(--text-main);
        }

        .logo-img {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            box-shadow: 0 0 15px var(--primary-glow);
        }

        .logo-text {
            font-size: 1.25rem;
            font-weight: 700;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #ffffff 0%, #cbd5e1 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .badge-live {
            background: rgba(16, 185, 129, 0.15);
            color: var(--primary);
            border: 1px solid rgba(16, 185, 129, 0.3);
            padding: 0.35rem 0.8rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .badge-live::before {
            content: '';
            width: 7px;
            height: 7px;
            background-color: var(--primary);
            border-radius: 50%;
            box-shadow: 0 0 8px var(--primary);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(0.95); opacity: 0.8; }
            50% { transform: scale(1.2); opacity: 1; }
            100% { transform: scale(0.95); opacity: 0.8; }
        }

        main {
            width: 100%;
            max-width: 1000px;
            padding: 2rem 1.5rem;
            text-align: center;
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .hero-tag {
            color: var(--primary);
            font-size: 0.9rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            margin-bottom: 1rem;
        }

        h1 {
            font-size: 3rem;
            font-weight: 800;
            line-height: 1.15;
            margin-bottom: 1.2rem;
            background: linear-gradient(135deg, #ffffff 0%, #94a3b8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        p.subtitle {
            font-size: 1.15rem;
            color: var(--text-muted);
            max-width: 650px;
            margin-bottom: 2.5rem;
            line-height: 1.6;
        }

        .download-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 1.2rem;
            justify-content: center;
            margin-bottom: 3rem;
            width: 100%;
            max-width: 550px;
        }

        .btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 1rem 1.8rem;
            border-radius: 14px;
            font-size: 1.05rem;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.25s ease;
            cursor: pointer;
            flex: 1;
            min-width: 240px;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-accent) 100%);
            color: #ffffff;
            box-shadow: 0 10px 25px var(--primary-glow);
            border: none;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 30px var(--primary-glow);
        }

        .btn-secondary {
            background: var(--bg-card);
            color: var(--text-main);
            border: 1px solid var(--border);
        }

        .btn-secondary:hover {
            background: var(--bg-card-hover);
            transform: translateY(-2px);
            border-color: rgba(255, 255, 255, 0.2);
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            width: 100%;
            margin-top: 1rem;
        }

        .feature-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 1.5rem;
            text-align: left;
            transition: transform 0.2s ease;
        }

        .feature-card:hover {
            transform: translateY(-4px);
            border-color: rgba(16, 185, 129, 0.3);
        }

        .feature-icon {
            font-size: 2rem;
            margin-bottom: 0.8rem;
        }

        .feature-title {
            font-size: 1.1rem;
            font-weight: 700;
            margin-bottom: 0.4rem;
        }

        .feature-desc {
            font-size: 0.9rem;
            color: var(--text-muted);
            line-height: 1.5;
        }

        footer {
            width: 100%;
            padding: 2rem 1.5rem;
            text-align: center;
            color: var(--text-muted);
            font-size: 0.85rem;
            border-top: 1px solid var(--border);
            margin-top: 3rem;
        }

        @media (max-width: 768px) {
            h1 { font-size: 2.2rem; }
            p.subtitle { font-size: 1rem; }
            .btn { width: 100%; }
        }
    </style>
</head>
<body>

    <header>
        <a href="#" class="logo-box">
            <img src="app/assets/assets/images/logo.png" alt="Dholera Logo" class="logo-img" onerror="this.src='app/favicon.png'">
            <span class="logo-text">DHOLERA REAL ESTATE</span>
        </a>
        <div class="badge-live">v1.0.0 Production Live</div>
    </header>

    <main>
        <div class="hero-tag">Official Mobile & Web Platform</div>
        <h1>Manage & Explore Dholera SIR Properties Effortlessly</h1>
        <p class="subtitle">
            Access verified real estate plots, survey numbers, TP/FP designations, and high-resolution photo galleries. Download the Android app for your phone or launch the web portal directly.
        </p>

        <div class="download-actions">
            <a href="app-release.apk" class="btn btn-primary">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                Download Android App (APK)
            </a>
            <a href="app/" class="btn btn-secondary">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                Launch Web App Portal
            </a>
        </div>

        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">🏘️</div>
                <div class="feature-title">Verified Land Listings</div>
                <div class="feature-desc">Filter plots by village name, survey number, zone designation, and plot area in Sq Yard or Bigha.</div>
            </div>
            <div class="feature-card">
                <div class="feature-icon">📱</div>
                <div class="feature-title">Responsive Layout Grid</div>
                <div class="feature-desc">Switch seamlessly between 1-column detail views and 2-column compact grid layouts on your mobile.</div>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🔄</div>
                <div class="feature-title">Auto In-App Updates</div>
                <div class="feature-desc">Get automatic mobile notifications whenever new features, screens, or listings are released.</div>
            </div>
        </div>
    </main>

    <footer>
        &copy; <?php echo date('Y'); ?> Dholera Real Estate. All rights reserved. | <a href="api/health.php" style="color: var(--primary); text-decoration: none;">API Health Check</a>
    </footer>

</body>
</html>
