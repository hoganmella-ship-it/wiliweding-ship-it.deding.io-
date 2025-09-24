<!-- Background Music -->
<audio id="bg-music" autoplay loop>
  <source src="musik.mp3" type="audio/mpeg">
</audio>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Willy & Nengsy</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f0fdf4; /* Sage Green background */
            color: #1f2937;
            scroll-behavior: smooth;
        }
        .text-sage {
            color: #344a3a;
        }
        .bg-sage {
            background-color: #344a3a;
        }
        .border-sage {
            border-color: #344a3a;
        }
        .text-accent {
            color: #d8c281;
        }
        .bg-accent {
            background-color: #d8c281;
        }
        .border-accent {
            border-color: #d8c281;
        }
        .divider {
            height: 1px;
            background-color: #e5e7eb;
            margin: 2rem 0;
        }
        .icon {
            font-size: 2rem;
            color: #344a3a;
        }
        .glass-container {
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            border-radius: 1rem;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        /* Custom styles for animations */
        .fade-in {
            animation: fadeIn 1.5s ease-in-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body class="overflow-x-hidden">

    <!-- Firebase SDKs from CDN -->
    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
        import { getAuth, signInAnonymously, signInWithCustomToken } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
        import { getFirestore, collection, addDoc, onSnapshot, query, orderBy, serverTimestamp, doc, setDoc } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";
        
        let db, auth, userId;
        const appId = typeof __app_id !== 'undefined' ? __app_id : 'default-app-id';
        
        // --- Firebase Initialization ---
        window.addEventListener('load', async () => {
            try {
                const firebaseConfig = {
  apiKey: "AIzaSyD4oIhLkbIvobMEWSteoOqa8YOKJZrqJBQ",
  authDomain: "badas-d4d68.firebaseapp.com",
  projectId: "badas-d4d68",
  storageBucket: "badas-d4d68.firebasestorage.app",
  messagingSenderId: "37305526832",
  appId: "1:37305526832:web:bffc4ed208a4efe6a41bf5",
  measurementId: "G-ZZD9F35JNL"
};
                const initialAuthToken = typeof __initial_auth_token !== 'undefined' ? __initial_auth_token : null;
                if (initialAuthToken) {
                    await signInWithCustomToken(auth, initialAuthToken);
                } else {
                    await signInAnonymously(auth);
                }
                
                userId = auth.currentUser?.uid || crypto.randomUUID();
                console.log("Firebase initialized. User ID:", userId);

                // Initialize guestbook listener after auth
                setupGuestbookListener();

            } catch (error) {
                console.error("Error initializing Firebase:", error);
            }
        });

        // --- Countdown Timer ---
        const countdownDate = new Date('2025-09-28T15:00:00');
        const countdownElement = document.getElementById('countdown');

        setInterval(() => {
            const now = new Date().getTime();
            const distance = countdownDate - now;

            const days = Math.floor(distance / (1000 * 60 * 60 * 24));
            const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((distance % (1000 * 60)) / 1000);

            if (distance < 0) {
                countdownElement.innerHTML = "Kami Telah Menikah!";
            } else {
                countdownElement.innerHTML = `
                    <div class="text-center">
                        <div class="text-4xl md:text-6xl font-bold text-sage">${days}</div>
                        <div class="text-xs md:text-sm text-gray-500 mt-1">Hari</div>
                    </div>
                    <div class="text-center">
                        <div class="text-4xl md:text-6xl font-bold text-sage">${hours}</div>
                        <div class="text-xs md:text-sm text-gray-500 mt-1">Jam</div>
                    </div>
                    <div class="text-center">
                        <div class="text-4xl md:text-6xl font-bold text-sage">${minutes}</div>
                        <div class="text-xs md:text-sm text-gray-500 mt-1">Menit</div>
                    </div>
                    <div class="text-center">
                        <div class="text-4xl md:text-6xl font-bold text-sage">${seconds}</div>
                        <div class="text-xs md:text-sm text-gray-500 mt-1">Detik</div>
                    </div>
                `;
            }
        }, 1000);

        // --- RSVP Form Submission ---
        const rsvpForm = document.getElementById('rsvp-form');
        const rsvpMessage = document.getElementById('rsvp-message');

        if (rsvpForm) {
            rsvpForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                const name = document.getElementById('rsvp-name').value;
                const status = document.getElementById('rsvp-status').value;
                const guests = document.getElementById('rsvp-guests').value;

                if (!name || !status) {
                    rsvpMessage.textContent = "Mohon isi nama dan status kehadiran.";
                    rsvpMessage.className = "text-red-500 mt-2";
                    return;
                }

                try {
                    const docRef = await addDoc(collection(db, `artifacts/${appId}/public/data/rsvps`), {
                        name: name,
                        status: status,
                        guests: parseInt(guests) || 0,
                        timestamp: serverTimestamp()
                    });
                    console.log("RSVP submitted with ID: ", docRef.id);
                    rsvpMessage.textContent = "Terima kasih, RSVP Anda telah kami terima!";
                    rsvpMessage.className = "text-green-500 mt-2";
                    rsvpForm.reset();
                } catch (e) {
                    console.error("Error adding document: ", e);
                    rsvpMessage.textContent = "Terjadi kesalahan saat mengirim RSVP. Silakan coba lagi.";
                    rsvpMessage.className = "text-red-500 mt-2";
                }
            });
        }
        
        // --- Guestbook (Ucapan) Form Submission and Display ---
        const guestbookForm = document.getElementById('guestbook-form');
        const greetingsList = document.getElementById('greetings-list');

        if (guestbookForm) {
            guestbookForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                const name = document.getElementById('guest-name').value;
                const message = document.getElementById('guest-message').value;

                if (!name || !message) {
                    return;
                }

                try {
                    await addDoc(collection(db, `artifacts/${appId}/public/data/greetings`), {
                        name: name,
                        message: message,
                        timestamp: serverTimestamp()
                    });
                    guestbookForm.reset();
                } catch (e) {
                    console.error("Error adding greeting: ", e);
                }
            });
        }

        function setupGuestbookListener() {
            try {
                const q = query(collection(db, `artifacts/${appId}/public/data/greetings`), orderBy("timestamp", "desc"));
                onSnapshot(q, (querySnapshot) => {
                    greetingsList.innerHTML = '';
                    querySnapshot.forEach((doc) => {
                        const data = doc.data();
                        const greetingCard = document.createElement('div');
                        greetingCard.className = "p-4 border border-sage rounded-xl shadow-lg my-2 fade-in bg-white";
                        greetingCard.innerHTML = `
                            <div class="flex items-center space-x-2 mb-2">
                                <ion-icon name="person-circle-outline" class="text-xl text-sage"></ion-icon>
                                <h4 class="font-semibold text-sage">${data.name}</h4>
                            </div>
                            <p class="text-sm italic text-gray-700">${data.message}</p>
                        `;
                        greetingsList.appendChild(greetingCard);
                    });
                });
            } catch (e) {
                console.error("Error setting up guestbook listener:", e);
            }
        }
    </script>

    <!-- Background Music Player -->
    <div id="music-player" class="fixed bottom-4 right-4 z-50">
        <audio id="background-music" loop>
            <source src="https://www.youtube.com/watch?v=BqFEtDsTUrQ" type="audio/mpeg">
        </audio>
        <button id="music-button" class="p-3 rounded-full bg-sage text-white shadow-lg focus:outline-none">
            <ion-icon name="musical-notes-outline" id="music-icon" class="text-xl"></ion-icon>
        </button>
        <script>
            const musicPlayer = document.getElementById('background-music');
            const musicButton = document.getElementById('music-button');
            const musicIcon = document.getElementById('music-icon');

            // Using YouTube's embed link to handle auto-play better
            const youtubeEmbedUrl = 'https://www.youtube.com/embed/BqFEtDsTUrQ?autoplay=1&mute=1&loop=1&controls=0&playlist=BqFEtDsTUrQ';
            const youtubePlayer = document.createElement('iframe');
            youtubePlayer.id = 'youtube-player';
            youtubePlayer.className = 'hidden';
            youtubePlayer.src = youtubeEmbedUrl;
            youtubePlayer.setAttribute('frameborder', '0');
            youtubePlayer.setAttribute('allow', 'autoplay; encrypted-media');
            document.body.appendChild(youtubePlayer);

            let isPlaying = false;
            musicButton.addEventListener('click', () => {
                const player = document.getElementById('youtube-player');
                if (isPlaying) {
                    player.contentWindow.postMessage('{"event":"command","func":"pauseVideo","args":""}', '*');
                    musicIcon.name = 'musical-notes-outline';
                } else {
                    player.contentWindow.postMessage('{"event":"command","func":"playVideo","args":""}', '*');
                    musicIcon.name = 'pause-outline';
                }
                isPlaying = !isPlaying;
            });
        </script>
    </div>

    <!-- Hero Section -->
    <header class="h-screen w-full relative flex flex-col justify-center items-center text-white text-center">
        <div class="absolute inset-0 bg-cover bg-center z-0" style="background-image: url('https://lh3.googleusercontent.com/d/1hHA2ZL-Bp0Zm4gfHiafLZC15czcMooCE');">
        </div>
        <div class="absolute inset-0 bg-black opacity-40 z-10"></div>
        <div class="relative z-20 fade-in flex flex-col items-center">
            <p class="text-lg md:text-xl font-light mb-2">Undangan Pernikahan</p>
            <h1 class="text-4xl md:text-7xl font-bold mb-4 font-serif">Willy & Nengsy</h1>
            <p class="text-sm md:text-base font-light mb-8">Minggu, 28 September 2025</p>
            <button onclick="document.getElementById('invitation-section').scrollIntoView({ behavior: 'smooth' })" class="px-6 py-2 bg-sage text-white rounded-full hover:bg-opacity-80 transition-all shadow-md">
                Buka Undangan
            </button>
        </div>
    </header>

    <main class="py-12 px-4 md:px-8">

        <!-- Invitation & Couple Section -->
        <section id="invitation-section" class="max-w-4xl mx-auto text-center py-12 fade-in">
            <h2 class="text-3xl md:text-4xl font-semibold mb-4 text-sage">Dengan segala kerendahan hati</h2>
            <p class="text-base md:text-lg mb-8 max-w-2xl mx-auto">
                Kami mengundang Bapak/Ibu/Saudara/i untuk hadir dalam acara pernikahan kami. Kehadiran Anda adalah anugerah terindah bagi kami.
            </p>
            
            <div class="bg-gray-100 p-6 rounded-2xl max-w-lg mx-auto mb-10">
                <p class="text-xs md:text-sm italic text-gray-600">
                    TUHAN Allah berfirman: "Tidak baik, kalau manusia itu seorang diri saja. Aku akan menjadikan penolong baginya, yang sepadan dengan dia."
                </p>
                <p class="text-xs md:text-sm font-semibold mt-2 text-gray-700">
                    Kejadian 2:18 TB
                </p>
            </div>

            <div class="grid md:grid-cols-2 gap-12 mt-12">
                <div>
                    <img src="https://lh3.googleusercontent.com/d/1vviYyDjJFY782EWNqcbyQ2CBy91zaxTG" onerror="this.src='https://placehold.co/500x500/A3B18A/283618?text=Foto\nTidak\nTersedia'" alt="Willy Diaz" class="rounded-full w-40 h-40 object-cover mx-auto mb-4 border-4 border-sage shadow-md">
                    <h3 class="text-2xl font-bold text-sage">Willy Diaz</h3>
                    <p class="text-sm text-gray-500 mt-2">Putra dari</p>
                    <p class="text-base text-gray-700 font-semibold">Bapak Antonius Diaz & Ibu Yakoba P Fanggitasi</p>
                </div>
                <div>
                    <img src="https://lh3.googleusercontent.com/d/1k4L6NL0cCXx28WeVAmrIz0KsYlm2Ft4B" onerror="this.src='https://placehold.co/500x500/A3B18A/283618?text=Foto\nTidak\nTersedia'" alt="Nengsy Leko" class="rounded-full w-40 h-40 object-cover mx-auto mb-4 border-4 border-sage shadow-md">
                    <h3 class="text-2xl font-bold text-sage">Nengsy Leko</h3>
                    <p class="text-sm text-gray-500 mt-2">Putri dari</p>
                    <p class="text-base text-gray-700 font-semibold">Bapak Yohanes Paulus Leko & Ibu Maria Chumayana</p>
                </div>
            </div>
        </section>

        <div class="divider"></div>

        <!-- Countdown Section -->
        <section class="max-w-4xl mx-auto text-center py-12 fade-in">
            <h2 class="text-3xl md:text-4xl font-semibold mb-8 text-sage">Menuju Hari Bahagia</h2>
            <div id="countdown" class="grid grid-cols-4 gap-4 md:gap-8 max-w-2xl mx-auto p-6 glass-container">
                <!-- Countdown timer will be populated by JS -->
            </div>
        </section>

        <div class="divider"></div>

        <!-- Event Details Section -->
        <section class="max-w-4xl mx-auto text-center py-12 fade-in">
            <h2 class="text-3xl md:text-4xl font-semibold mb-8 text-sage">Rangkaian Acara</h2>
            <div class="grid md:grid-cols-2 gap-8">
                <div class="bg-white p-6 rounded-2xl shadow-lg border border-sage/50">
                    <ion-icon name="heart-circle-outline" class="icon"></ion-icon>
                    <h3 class="text-xl font-bold mt-4 mb-2 text-sage">Pemberkatan Nikah</h3>
                    <p class="text-sm text-gray-500">Minggu, 28 September 2025</p>
                    <p class="text-xl font-semibold mt-2 mb-4">15:00 WITA</p>
                    <p class="text-base text-gray-700">Gereja Katolik Santo Silvester Pecatu Dreamland</p>
                </div>
                <div class="bg-white p-6 rounded-2xl shadow-lg border border-sage/50">
                    <ion-icon name="restaurant-outline" class="icon"></ion-icon>
                    <h3 class="text-xl font-bold mt-4 mb-2 text-sage">Resepsi Pernikahan</h3>
                    <p class="text-sm text-gray-500">Minggu, 28 September 2025</p>
                    <p class="text-xl font-semibold mt-2 mb-4">18:59 WITA</p>
                    <p class="text-base text-gray-700">Ballroom Gereja Katolik St. Silvester Pecatu</p>
                </div>
            </div>
        </section>

        <div class="divider"></div>
        
        <!-- Google Maps Section -->
        <section class="max-w-4xl mx-auto text-center py-12 fade-in">
            <h2 class="text-3xl md:text-4xl font-semibold mb-8 text-sage">Peta Lokasi</h2>
            <div class="relative overflow-hidden rounded-2xl shadow-lg border border-sage/50 w-full" style="padding-top: 56.25%;">
                <iframe class="absolute top-0 left-0 w-full h-full" src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3942.279627670966!2d115.11181167448265!3d-8.79093399080644!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2dd25b303102179d%3A0xc682245b0d0c3545!2sGereja%20Katolik%20St.%20Silvester%20Pecatu!5e0!3m2!1sid!2sid!4v1699948493121!5m2!1sid!2sid" allowfullscreen="" loading="lazy"></iframe>
            </div>
        </section>
        
        <div class="divider"></div>

        <!-- Gallery Section -->
        <section class="max-w-4xl mx-auto text-center py-12 fade-in">
            <h2 class="text-3xl md:text-4xl font-semibold mb-8 text-sage">Galeri Foto</h2>
            <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
                <img src="https://lh3.googleusercontent.com/d/1Fb3FHRr5i6H0FUHDPDRMxwlD31mbjG_0" onerror="this.src='https://placehold.co/400x500/A3B18A/283618?text=Foto\nTidak\nTersedia'" class="w-full h-64 object-cover rounded-xl shadow-lg hover:scale-105 transition-transform" alt="Pasangan Willy & Nengsy">
                <img src="https://lh3.googleusercontent.com/d/1JFHOoY-F1a3vmoKHimYWRfx3VO82N0QE" onerror="this.src='https://placehold.co/400x500/A3B18A/283618?text=Foto\nTidak\nTersedia'" class="w-full h-64 object-cover rounded-xl shadow-lg hover:scale-105 transition-transform" alt="Pasangan Willy & Nengsy">
                <img src="https://lh3.googleusercontent.com/d/11pjkJpNutRs6OwCE6SfRo0fmUbj-4Xn1" onerror="this.src='https://placehold.co/400x500/A3B18A/283618?text=Foto\nTidak\nTersedia'" class="w-full h-64 object-cover rounded-xl shadow-lg hover:scale-105 transition-transform" alt="Pasangan Willy & Nengsy">
                <img src="https://lh3.googleusercontent.com/d/1br670JCVHrg5mmI6rNftIms0PMYycLAo" onerror="this.src='https://placehold.co/400x500/A3B18A/283618?text=Foto\nTidak\nTersedia'" class="w-full h-64 object-cover rounded-xl shadow-lg hover:scale-105 transition-transform" alt="Pasangan Willy & Nengsy">
                <img src="https://lh3.googleusercontent.com/d/1maD9JjTHm1D8UfWAi4DdgZiBukmmgtUh" onerror="this.src='https://placehold.co/400x500/A3B18A/283618?text=Foto\nTidak\nTersedia'" class="w-full h-64 object-cover rounded-xl shadow-lg hover:scale-105 transition-transform" alt="Pasangan Willy & Nengsy">
                <img src="https://lh3.googleusercontent.com/d/1aggzAkW3d1a0WFikmbiBnlHBDZUWC_FE" onerror="this.src='https://placehold.co/400x500/A3B18A/283618?text=Foto\nTidak\nTersedia'" class="w-full h-64 object-cover rounded-xl shadow-lg hover:scale-105 transition-transform" alt="Pasangan Willy & Nengsy">
            </div>
        </section>

        <div class="divider"></div>

        <!-- RSVP Section -->
        <section class="max-w-xl mx-auto text-center py-12 fade-in">
            <h2 class="text-3xl md:text-4xl font-semibold mb-8 text-sage">Konfirmasi Kehadiran</h2>
            <form id="rsvp-form" class="bg-white p-8 rounded-2xl shadow-lg border border-sage/50 space-y-4">
                <input id="rsvp-name" type="text" placeholder="Nama Anda" class="w-full p-3 rounded-lg border-2 border-gray-200 focus:border-sage focus:outline-none transition-all" required>
                <select id="rsvp-status" class="w-full p-3 rounded-lg border-2 border-gray-200 focus:border-sage focus:outline-none transition-all" required>
                    <option value="">Status Kehadiran</option>
                    <option value="Hadir">Akan Hadir</option>
                    <option value="Tidak Hadir">Tidak Dapat Hadir</option>
                </select>
                <input id="rsvp-guests" type="number" min="0" placeholder="Jumlah tamu yang hadir (termasuk Anda)" class="w-full p-3 rounded-lg border-2 border-gray-200 focus:border-sage focus:outline-none transition-all">
                <button type="submit" class="w-full py-3 bg-sage text-white font-semibold rounded-lg hover:opacity-90 transition-opacity">Kirim</button>
            </form>
            <p id="rsvp-message" class="mt-4 text-sm"></p>
        </section>

        <div class="divider"></div>

        <!-- Wedding Gift Section -->
        <section class="max-w-xl mx-auto text-center py-12 fade-in">
            <h2 class="text-3xl md:text-4xl font-semibold mb-8 text-sage">Wedding Gift</h2>
            <div class="bg-white p-8 rounded-2xl shadow-lg border border-sage/50">
                <div class="flex flex-col items-center space-y-4">
                    <ion-icon name="gift-outline" class="icon text-3xl"></ion-icon>
                    <p class="text-sm text-gray-700">Doa restu dari Anda adalah hadiah terindah bagi kami. Namun, jika Anda ingin memberikan hadiah, kami telah menyiapkan amplop digital.</p>
                    <p class="text-xl font-bold text-sage">BCA 772 1079086</p>
                    <button id="copy-bank" class="px-4 py-2 bg-sage text-white text-sm rounded-full hover:opacity-90 transition-opacity flex items-center space-x-2">
                        <ion-icon name="copy-outline"></ion-icon>
                        <span>Salin No. Rekening</span>
                    </button>
                </div>
            </div>
            <script>
                document.getElementById('copy-bank').addEventListener('click', () => {
                    const textToCopy = '7721079086';
                    const tempInput = document.createElement('input');
                    tempInput.value = textToCopy;
                    document.body.appendChild(tempInput);
                    tempInput.select();
                    document.execCommand('copy');
                    document.body.removeChild(tempInput);
                    const button = document.getElementById('copy-bank');
                    const originalText = button.innerHTML;
                    button.innerHTML = '<ion-icon name="checkmark-outline"></ion-icon><span>Disalin!</span>';
                    setTimeout(() => {
                        button.innerHTML = originalText;
                    }, 2000);
                });
            </script>
        </section>

        <div class="divider"></div>

        <!-- Guestbook Section -->
        <section class="max-w-xl mx-auto text-center py-12 fade-in">
            <h2 class="text-3xl md:text-4xl font-semibold mb-8 text-sage">Ucapan & Doa</h2>
            <p class="mb-6 text-gray-600">Kepada Bapak/Ibu/Saudara/i yang ingin memberikan ucapan kepada kami, dapat dituliskan di bawah ini.</p>
            
            <!-- Guestbook Form -->
            <form id="guestbook-form" class="bg-white p-8 rounded-2xl shadow-lg border border-sage/50 space-y-4 mb-8">
                <input id="guest-name" type="text" placeholder="Nama Anda" class="w-full p-3 rounded-lg border-2 border-gray-200 focus:border-sage focus:outline-none transition-all" required>
                <textarea id="guest-message" placeholder="Tuliskan ucapan dan doa terbaik Anda..." rows="4" class="w-full p-3 rounded-lg border-2 border-gray-200 focus:border-sage focus:outline-none transition-all" required></textarea>
                <button type="submit" class="w-full py-3 bg-sage text-white font-semibold rounded-lg hover:opacity-90 transition-opacity">Kirim Ucapan</button>
            </form>
            
            <!-- Greetings List -->
            <div id="greetings-list" class="space-y-4 max-h-96 overflow-y-auto pr-2">
                <!-- Greetings will be populated by JS from Firestore -->
            </div>
        </section>

        <div class="divider"></div>

        <!-- Closing Section -->
        <section class="max-w-4xl mx-auto text-center py-12 fade-in">
            <img src="https://lh3.googleusercontent.com/d/1LJB-W6FQiN_Kusi9ihwnw-W-W8nTMQjz" onerror="this.src='https://placehold.co/400x400/A3B18A/283618?text=Foto\nPasangan'" alt="Willy & Nengsy" class="w-full max-w-sm mx-auto rounded-full object-cover mb-8 border-4 border-sage shadow-lg">
            <p class="text-xl md:text-2xl font-semibold mb-2 text-sage">Terima Kasih</p>
            <p class="text-base text-gray-600">
                Merupakan suatu kehormatan dan kebahagiaan bagi kami, apabila Bapak/Ibu/Saudara/i berkenan hadir untuk memberikan doa restu.
            </p>
            <p class="text-lg font-bold mt-4 text-sage">Willy & Nengsy</p>
        </section>

    </main>
</body>
</html>
