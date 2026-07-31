<?php
/**
 * Dholera Real Estate — Official Landing & Download Page
 */
$latestVersion = '1.0.3';
$versionFile = __DIR__ . '/api/config/version.php';
if (file_exists($versionFile)) {
    $content = file_get_contents($versionFile);
    if (preg_match('/"latest_version"\s*=>\s*"([^"]+)"/', $content, $matches)) {
        $latestVersion = $matches[1];
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dholera Real Estate — Official Mobile App & Web Portal</title>
    <meta name="description" content="Official Property Management & Listing Platform for Dholera SIR. Download the Android app or access the live web portal.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-body: #f8fafc;
            --bg-card: #ffffff;
            --navy-dark: #0f172a;
            --navy-primary: #1e3a8a;
            --emerald-primary: #047857;
            --emerald-hover: #065f46;
            --text-dark: #0f172a;
            --text-muted: #64748b;
            --border-light: #e2e8f0;
            --shadow-classic: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
            --shadow-hover: 0 10px 15px -3px rgba(0, 0, 0, 0.08), 0 4px 6px -2px rgba(0, 0, 0, 0.04);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        body {
            background-color: var(--bg-body);
            color: var(--text-dark);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: space-between;
        }

        /* Top Navigation Header */
        header {
            width: 100%;
            background-color: #ffffff;
            border-bottom: 1px solid var(--border-light);
            padding: 1.2rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header-container {
            max-width: 1100px;
            width: 100%;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .brand-logo {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
        }

        .brand-logo img {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            object-fit: cover;
        }

        .brand-name {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--navy-dark);
            letter-spacing: -0.3px;
        }

        .status-badge {
            background-color: #f0fdf4;
            color: var(--emerald-primary);
            border: 1px solid #bbf7d0;
            padding: 0.35rem 0.85rem;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        /* Main Hero Section */
        main {
            max-width: 900px;
            width: 100%;
            padding: 3.5rem 1.5rem;
            text-align: center;
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .hero-category {
            color: var(--navy-primary);
            font-size: 0.85rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 1rem;
        }

        h1 {
            font-size: 2.6rem;
            font-weight: 800;
            color: var(--navy-dark);
            line-height: 1.25;
            margin-bottom: 1.2rem;
            letter-spacing: -0.5px;
        }

        p.hero-subtitle {
            font-size: 1.1rem;
            color: var(--text-muted);
            line-height: 1.6;
            max-width: 680px;
            margin-bottom: 2.5rem;
        }

        /* Action Buttons Box */
        .actions-box {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            justify-content: center;
            width: 100%;
            max-width: 520px;
            margin-bottom: 3.5rem;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 0.95rem 1.8rem;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.2s ease;
            cursor: pointer;
            flex: 1;
            min-width: 230px;
        }

        .btn-download {
            background-color: var(--emerald-primary);
            color: #ffffff;
            border: 1px solid var(--emerald-primary);
            box-shadow: var(--shadow-classic);
        }

        .btn-download:hover {
            background-color: var(--emerald-hover);
            transform: translateY(-1px);
            box-shadow: var(--shadow-hover);
        }

        .btn-portal {
            background-color: #ffffff;
            color: var(--navy-dark);
            border: 1px solid var(--border-light);
            box-shadow: var(--shadow-classic);
        }

        .btn-portal:hover {
            background-color: #f1f5f9;
            transform: translateY(-1px);
            box-shadow: var(--shadow-hover);
        }

        /* Feature Cards Grid */
        .features-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 1.5rem;
            width: 100%;
            text-align: left;
        }

        .card {
            background-color: var(--bg-card);
            border: 1px solid var(--border-light);
            border-radius: 12px;
            padding: 1.8rem;
            box-shadow: var(--shadow-classic);
            transition: all 0.2s ease;
        }

        .card:hover {
            box-shadow: var(--shadow-hover);
            border-color: #cbd5e1;
        }

        .card-icon-box {
            width: 48px;
            height: 48px;
            background-color: #f1f5f9;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.2rem;
            font-size: 1.5rem;
        }

        .card-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--navy-dark);
            margin-bottom: 0.5rem;
        }

        .card-desc {
            font-size: 0.92rem;
            color: var(--text-muted);
            line-height: 1.55;
        }

        /* Footer */
        footer {
            width: 100%;
            background-color: #ffffff;
            border-top: 1px solid var(--border-light);
            padding: 1.8rem 1.5rem;
            text-align: center;
            color: var(--text-muted);
            font-size: 0.88rem;
        }

        footer a {
            color: var(--navy-primary);
            text-decoration: none;
            font-weight: 500;
        }

        footer a:hover {
            text-decoration: underline;
        }

        @media (max-width: 640px) {
            h1 { font-size: 2rem; }
            main { padding: 2.5rem 1.2rem; }
            .btn { width: 100%; }
        }
    </style>
</head>
<body>

    <header>
        <div class="header-container">
            <a href="#" class="brand-logo">
                <img src="app/assets/assets/images/logo.png" alt="Dholera Logo" onerror="this.src='app/favicon.png'">
                <span class="brand-name">DHOLERA REAL ESTATE</span>
            </a>
            <div class="status-badge">Official Release v<?php echo htmlspecialchars($latestVersion); ?></div>
        </div>
    </header>

    <main>
        <div class="hero-category">Dholera SIR Property Portal</div>
        <h1>Real Estate Property Management & Land Directory</h1>
        <p class="hero-subtitle">
            Access verified real estate plots, survey numbers, TP/FP zone details, and property photo galleries across Dholera Special Investment Region.
        </p>

        <div class="actions-box">
            <a href="download_apk.php" class="btn btn-download">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                Download Android App (v<?php echo htmlspecialchars($latestVersion); ?>)
            </a>
            <a href="app/" class="btn btn-portal">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                Launch Web Portal
            </a>
        </div>

        <div class="features-container">
            <div class="card">
                <div class="card-icon-box">🏛️</div>
                <div class="card-title">Verified Land Listings</div>
                <div class="card-desc">Filter plots by village name, survey number, zone designation, and plot area measurements in Sq Yard or Bigha.</div>
            </div>
            <div class="card">
                <div class="card-icon-box">📱</div>
                <div class="card-title">Responsive Mobile Layout</div>
                <div class="card-desc">Switch between single-column detailed view and multi-column grid view optimized for all mobile screens.</div>
            </div>
            <div class="card">
                <div class="card-icon-box">🔒</div>
                <div class="card-title">Role-Based Access</div>
                <div class="card-desc">Secure JWT session management for Super Admin administration and authorized user access.</div>
            </div>
        </div>
    </main>

    <footer>
        &copy; <?php echo date('Y'); ?> Dholera Real Estate. All rights reserved. | <a href="api/health.php">System Health Check</a>
    </footer>

</body>
</html>
