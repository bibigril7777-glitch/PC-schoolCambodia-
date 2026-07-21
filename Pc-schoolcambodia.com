<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EduShop App v4.1</title>
    <style>
        :root {
            --bg-color: #f0f2f5;
            --text-color: #333333;
            --card-bg: #ffffff;
            --primary: #1877f2;
            --primary-hover: #166fe5;
            --border: #ccd0d5;
            --navbar-bg: #ffffff;
        }

        /* OLED Dark Mode */
        [data-theme="dark"] {
            --bg-color: #000000;
            --text-color: #e4e6eb;
            --card-bg: #18191a;
            --primary: #2d88ff;
            --primary-hover: #1b74e4;
            --border: #3a3b3c;
            --navbar-bg: #242526;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', 'Hanuman', Tahoma, sans-serif;
            transition: background-color 0.3s, color 0.3s;
        }

        body {
            background-color: var(--bg-color);
            color: var(--text-color);
        }

        /* Navbar */
        header {
            background-color: var(--navbar-bg);
            border-bottom: 1px solid var(--border);
            padding: 12px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .logo { font-size: 1.5rem; font-weight: bold; color: var(--primary); }

        nav button {
            background: none;
            border: none;
            color: var(--text-color);
            font-size: 1rem;
            margin-left: 10px;
            cursor: pointer;
            font-weight: 500;
            padding: 5px 8px;
        }

        nav button.active {
            color: var(--primary);
            border-bottom: 2px solid var(--primary);
        }

        .btn-primary {
            background-color: var(--primary);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
        }
        .btn-primary:hover { background-color: var(--primary-hover); }

        /* Container & Tabs */
        .container { max-width: 1000px; margin: 20px auto; padding: 0 15px; }
        .tab-content { display: none; animation: fadeIn 0.3s; }
        .tab-content.active { display: block; }

        @keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }

        /* Shop */
        .product-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 15px; }
        .product-card { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; padding: 15px; text-align: center; }
        .product-card img { width: 100%; height: 140px; object-fit: cover; border-radius: 5px; margin-bottom: 10px; }
        .product-price { font-size: 1.2rem; color: var(--primary); margin: 10px 0; font-weight: bold; }

        /* Exam */
        .exam-container { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; padding: 20px; }
        .question-block { margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid var(--border); }
        .option-label { display: block; margin-bottom: 8px; cursor: pointer; }
        #exam-result { margin-top: 15px; font-weight: bold; font-size: 1.2rem; }

        /* Feed System */
        .post-creator { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; padding: 15px; margin-bottom: 20px; }
        .post-creator textarea { width: 100%; height: 80px; padding: 10px; border: 1px solid var(--border); border-radius: 6px; background-color: var(--bg-color); color: var(--text-color); resize: none; margin-bottom: 10px; }
        .post-actions { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }
        
        .file-upload-wrapper { position: relative; overflow: hidden; display: inline-block; }
        .file-upload-wrapper input[type=file] { font-size: 100px; position: absolute; left: 0; top: 0; opacity: 0; cursor: pointer; }
        .btn-upload { background-color: var(--bg-color); border: 1px solid var(--border); padding: 6px 12px; border-radius: 6px; cursor: pointer; display: flex; align-items: center; gap: 5px; color: var(--text-color); }
        
        select { padding: 6px; border-radius: 6px; border: 1px solid var(--border); background-color: var(--bg-color); color: var(--text-color); }
        
        /* Post Feed Cards */
        .post-card { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 8px; padding: 15px; margin-bottom: 15px; }
        .post-header { display: flex; align-items: center; margin-bottom: 10px; }
        .role-badge { padding: 3px 8px; border-radius: 12px; font-size: 0.8rem; font-weight: bold; margin-right: 10px; color: white; }
        .role-teacher { background-color: #e0245e; }
        .role-student { background-color: var(--primary); }
        
        .post-media { margin-top: 10px; border-radius: 8px; overflow: hidden; border: 1px solid var(--border); }
        .post-media img, .post-media video { width: 100%; max-height: 400px; object-fit: contain; background: #000; display: block; }
        .post-file { padding: 15px; background: var(--bg-color); display: flex; align-items: center; gap: 10px; font-weight: bold; }

    </style>
</head>
<body>

    <!-- Header / Navbar -->
    <header>
        <div class="logo">App v4.1</div>
        <nav>
            <button class="nav-btn active" onclick="switchTab('feed')" data-i18n="nav_feed">Feed</button>
            <button class="nav-btn" onclick="switchTab('shop')" data-i18n="nav_shop">Shop</button>
            <button class="nav-btn" onclick="switchTab('exam')" data-i18n="nav_exam">Exam</button>
            <button onclick="toggleLang()">🌐 <span id="lang-indicator">EN</span></button>
            <button onclick="toggleTheme()">🌓</button>
        </nav>
    </header>

    <div class="container">
        
        <!-- FEED TAB (NEW) -->
        <div id="feed" class="tab-content active">
            <h2 data-i18n="feed_title">Classroom Feed</h2><br>
            
            <div class="post-creator">
                <textarea id="post-text" placeholder="Write something... / សរសេរអ្វីមួយ..."></textarea>
                <div class="post-actions">
                    <div style="display: flex; gap: 10px;">
                        <select id="post-role">
                            <option value="student" data-i18n="role_student">Student</option>
                            <option value="teacher" data-i18n="role_teacher">Teacher</option>
                        </select>
                        <div class="file-upload-wrapper">
                            <button class="btn-upload">🗃️ <span id="file-name-display" data-i18n="upload_btn">Photo/Video/File</span></button>
                            <input type="file" id="post-file" accept="image/*,video/*,.pdf,.doc,.docx,.zip,.rar" onchange="updateFileName()">
                        </div>
                    </div>
                    <button class="btn-primary" onclick="submitPost()" data-i18n="post_btn">Post</button>
                </div>
            </div>

            <div id="feed-list">
                <!-- Posts inject here -->
            </div>
        </div>

        <!-- SHOP TAB -->
        <div id="shop" class="tab-content">
            <h2 data-i18n="shop_title">Latest Products</h2><br>
            <div class="product-grid" id="product-list"></div>
        </div>

        <!-- EXAM TAB -->
        <div id="exam" class="tab-content">
            <div class="exam-container">
                <h2 data-i18n="exam_title">Mathematics Exam</h2><br>
                <form id="quiz-form">
                    <div id="quiz-list"></div>
                    <button type="button" class="btn-primary" onclick="submitExam()" data-i18n="submit_exam">Submit Answers</button>
                    <div id="exam-result"></div>
                </form>
            </div>
        </div>

    </div>

    <script>
        // --- 1. Language System ---
        let currentLang = 'en';
        const i18n = {
            en: {
                nav_feed: "Feed", nav_shop: "Shop", nav_exam: "Exam",
                feed_title: "Classroom Feed", upload_btn: "Photo/Video/File", post_btn: "Post",
                role_student: "Student", role_teacher: "Teacher",
                shop_title: "Latest Materials", add_cart: "Add to Cart",
                exam_title: "Final Exam", submit_exam: "Submit Answers",
                products: [
                    { name: "Web Dev Course", price: 49.99 },
                    { name: "Mathematics E-Book", price: 19.99 },
                    { name: "Pro Android Code v4.1", price: 99.99 }
                ],
                questions: [
                    { q: "What is the result of 5 x 5?", options: ["10", "20", "25", "55"], ans: "25" },
                    { q: "What does HTML stand for?", options: ["Hyper Text", "Home Tool", "Hyperlinks", "None"], ans: "Hyper Text" }
                ]
            },
            km: {
                nav_feed: "ព័ត៌មាន", nav_shop: "ទិញទំនិញ", nav_exam: "ការប្រឡង",
                feed_title: "ព័ត៌មានថ្នាក់រៀន", upload_btn: "រូបភាព/វីដេអូ/ឯកសារ", post_btn: "បង្ហោះ",
                role_student: "សិស្ស", role_teacher: "គ្រូបង្រៀន",
                shop_title: "សម្ភារៈសិក្សាថ្មីៗ", add_cart: "ទិញ",
                exam_title: "ការប្រឡងបញ្ចប់វគ្គ", submit_exam: "បញ្ជូនចម្លើយ",
                products: [
                    { name: "វគ្គសិក្សង្កើតវិបសាយ", price: 49.99 },
                    { name: "សៀវភៅគណិតវិទ្យា", price: 19.99 },
                    { name: "កូដ Android v4.1", price: 99.99 }
                ],
                questions: [
                    { q: "តើ 5 x 5 ស្មើនឹងប៉ុន្មាន?", options: ["10", "20", "25", "55"], ans: "25" },
                    { q: "តើ HTML តំណាងឲ្យអ្វី?", options: ["Hyper Text", "Home Tool", "Hyperlinks", "គ្មានចម្លើយ"], ans: "Hyper Text" }
                ]
            }
        };

        function toggleLang() {
            currentLang = currentLang === 'en' ? 'km' : 'en';
            document.getElementById('lang-indicator').innerText = currentLang.toUpperCase();
            applyLanguage();
        }

        function applyLanguage() {
            // Update UI text
            document.querySelectorAll('[data-i18n]').forEach(el => {
                const key = el.getAttribute('data-i18n');
                if (i18n[currentLang][key]) {
                    el.innerText = i18n[currentLang][key];
                }
            });
            // Re-render dynamic content
            renderProducts();
            renderExam();
        }

        // --- 2. Feed & Upload System ---
        function updateFileName() {
            const input = document.getElementById('post-file');
            const display = document.getElementById('file-name-display');
            if(input.files.length > 0) {
                let name = input.files[0].name;
                display.innerText = name.length > 15 ? name.substring(0,15) + "..." : name;
            } else {
                display.innerText = i18n[currentLang].upload_btn;
            }
        }

        function submitPost() {
            const text = document.getElementById('post-text').value;
            const role = document.getElementById('post-role').value;
            const fileInput = document.getElementById('post-file');
            
            if(!text && fileInput.files.length === 0) return alert("Please enter text or select a file!");

            let mediaHtml = '';
            if(fileInput.files.length > 0) {
                const file = fileInput.files[0];
                const fileUrl = URL.createObjectURL(file); // Local preview URL
                
                if(file.type.startsWith('image/')) {
                    mediaHtml = `<div class="post-media"><img src="${fileUrl}" alt="Posted Image"></div>`;
                } else if(file.type.startsWith('video/')) {
                    mediaHtml = `<div class="post-media"><video controls src="${fileUrl}"></video></div>`;
                } else {
                    mediaHtml = `<div class="post-media post-file">🗂️ ${file.name} (File)</div>`;
                }
            }

            const postHtml = `
                <div class="post-card">
                    <div class="post-header">
                        <span class="role-badge ${role === 'teacher' ? 'role-teacher' : 'role-student'}">
                            ${role.toUpperCase()}
                        </span>
                        <small style="color: gray;">Just now</small>
                    </div>
                    <p>${text.replace(/\n/g, '<br>')}</p>
                    ${mediaHtml}
                </div>
            `;

            // Insert at the top of the feed
            const feedList = document.getElementById('feed-list');
            feedList.insertAdjacentHTML('afterbegin', postHtml);

            // Reset form
            document.getElementById('post-text').value = '';
            fileInput.value = '';
            updateFileName();
        }

        // --- 3. Shop & Exam Rendering ---
        function renderProducts() {
            const data = i18n[currentLang].products;
            const btnText = i18n[currentLang].add_cart;
            document.getElementById('product-list').innerHTML = data.map(p => `
                <div class="product-card">
                    <div style="height:120px; background:var(--border); border-radius:5px; margin-bottom:10px;"></div>
                    <h3>${p.name}</h3>
                    <div class="product-price">$${p.price.toFixed(2)}</div>
                    <button class="btn-primary">${btnText}</button>
                </div>
            `).join('');
        }

        function renderExam() {
            const data = i18n[currentLang].questions;
            document.getElementById('quiz-list').innerHTML = data.map((q, i) => `
                <div class="question-block">
                    <div style="font-weight:bold; margin-bottom:10px;">${i + 1}. ${q.q}</div>
                    ${q.options.map(opt => `
                        <label class="option-label">
                            <input type="radio" name="q${i}" value="${opt}"> ${opt}
                        </label>
                    `).join('')}
                </div>
            `).join('');
            document.getElementById('exam-result').innerText = "";
        }

        function submitExam() {
            const data = i18n[currentLang].questions;
            let score = 0;
            data.forEach((q, i) => {
                const selected = document.querySelector(`input[name="q${i}"]:checked`);
                if (selected && selected.value === q.ans) score++;
            });
            document.getElementById('exam-result').innerText = 
                currentLang === 'en' ? `Score: ${score} / ${data.length}` : `ពិន្ទុរបស់អ្នក: ${score} / ${data.length}`;
            document.getElementById('exam-result').style.color = "var(--primary)";
        }

        // --- 4. Navigation & Theme ---
        function switchTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
            event.target.classList.add('active');
        }

        function toggleTheme() {
            const html = document.documentElement;
            html.setAttribute('data-theme', html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
        }

        // Init
        window.onload = applyLanguage;
    </script>
</body>
</html>
