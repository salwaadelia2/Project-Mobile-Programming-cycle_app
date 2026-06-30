-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 27 Jun 2026 pada 17.17
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cycle_app`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `menstruasi`
--

CREATE TABLE `menstruasi` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `tanggal_mulai` date NOT NULL,
  `tanggal_selesai` date DEFAULT NULL,
  `siklus_ke` int(11) DEFAULT 1,
  `catatan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `mood`
--

CREATE TABLE `mood` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `mood` enum('Senang','Sedih','Kesal','Marah','Cemas','Tenang','Lelah') NOT NULL,
  `catatan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tips`
--

CREATE TABLE `tips` (
  `id` int(11) NOT NULL,
  `mood` enum('Senang','Sedih','Kesal','Marah','Cemas','Tenang','Lelah') NOT NULL,
  `tips` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tips`
--

INSERT INTO `tips` (`id`, `mood`, `tips`) VALUES
(1, 'Kesal', '💆‍♀️ Coba tarik napas dalam-dalam, minum air putih, dan istirahat sejenak. Kamu hebat!'),
(2, 'Marah', '🧘‍♀️ Ambil jeda, dengarkan musik favorit, atau tulis perasaanmu di buku.'),
(3, 'Sedih', '🥺 Nangis gapapa kok. Kamu berhak merasa sedih. Coba cerita ke teman atau keluarga.'),
(4, 'Cemas', '🌿 Tarik napas 4 detik, tahan 4 detik, hembuskan 4 detik. Ulangi 5 kali.'),
(5, 'Lelah', '🛌 Istirahat yang cukup. Jangan paksakan diri. Tubuhmu butuh waktu untuk pulih.'),
(6, 'Tenang', '✨ Nikmati momen ini. Kamu sudah melakukan yang terbaik!'),
(7, 'Senang', '🥳 Rayakan kebahagiaanmu! Lakukan hal yang kamu suka.'),
(8, 'Kesal', '💬 Ajak dia ngobrol pelan-pelan. Tanyakan apa yang dia rasakan. Jangan paksa cerita.'),
(9, 'Marah', '🤫 Beri dia ruang dulu. Siapkan minuman kesukaannya. Biarkan dia tenang dulu.'),
(10, 'Sedih', '🤗 Peluk dia erat. Kadang pelukan lebih berarti dari kata-kata.'),
(11, 'Cemas', '🎧 Tawarkan dia mendengarkan musik favorit atau tonton film bareng.'),
(12, 'Lelah', '🍲 Masak/makanan kesukaannya. Bantu dia istirahat.'),
(13, 'Tenang', '❤️ Nikmati waktu bersama. Quality time itu penting!'),
(14, 'Senang', '🎉 Rayakan kebahagiaanmu berdua! Ajak dia jalan-jalan atau nonton.'),
(15, 'Kesal', '😮‍💨 Coba keluar rumah sebentar, hirup udara segar, ambil jeda!'),
(16, 'Marah', '💢 Hitung 1-10, tarik napas, jangan buat keputusan saat marah.'),
(17, 'Sedih', '😢 Menangis itu sehat. Coba tulis perasaanmu atau bicara dengan orang terpercaya.'),
(18, 'Cemas', '🧘 Coba teknik pernapasan 4-7-8: tarik 4 detik, tahan 7 detik, hembus 8 detik.'),
(19, 'Lelah', '😴 Prioritaskan istirahat. Tubuh butuh pemulihan.'),
(20, 'Tenang', '🌿 Nikmati ketenangan ini. Kamu layak bahagia.'),
(21, 'Senang', '🎊 Bagikan kebahagiaanmu dengan orang lain! Senyum itu menular.');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `created_at`) VALUES
(3, 'salwa', '12345', '2026-06-26 10:46:11'),
(4, 'awa', '12345', '2026-06-26 11:26:57'),
(5, 'ade', '12345', '2026-06-27 14:39:48');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `menstruasi`
--
ALTER TABLE `menstruasi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `mood`
--
ALTER TABLE `mood`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `tips`
--
ALTER TABLE `tips`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `menstruasi`
--
ALTER TABLE `menstruasi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT untuk tabel `mood`
--
ALTER TABLE `mood`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `tips`
--
ALTER TABLE `tips`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `menstruasi`
--
ALTER TABLE `menstruasi`
  ADD CONSTRAINT `menstruasi_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `mood`
--
ALTER TABLE `mood`
  ADD CONSTRAINT `mood_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
