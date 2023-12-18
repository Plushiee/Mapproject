-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 18, 2023 at 03:10 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mapproject`
--

-- --------------------------------------------------------

--
-- Table structure for table `72210456`
--

CREATE TABLE `72210456` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `kategori` varchar(100) DEFAULT NULL,
  `keterangan` varchar(100) DEFAULT NULL,
  `lat` double DEFAULT NULL,
  `lng` double DEFAULT NULL,
  `jamBuka` varchar(100) DEFAULT '',
  `jamTutup` varchar(100) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `72210456`
--

INSERT INTO `72210456` (`id`, `nama`, `kategori`, `keterangan`, `lat`, `lng`, `jamBuka`, `jamTutup`) VALUES
(13, 'Rumah Makan Bersahabat', 'Rumah Makan', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin at libero feugiat, tincidunt risus a,', -7.785873534861289, 110.38021387616006, '', ''),
(14, 'Rumah Makan Seru Bersama', 'Rumah Makan', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin at libero feugiat, tincidunt risus a,', -7.784912671476383, 110.38178210816237, '6:54', '18:54'),
(15, 'Mal', 'Things To do', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi a euismod leo. Aliquam erat volutpat.', -7.783427635554887, 110.37861990124992, '14:31', '12:31'),
(16, 'Apotek K-24', 'Kesehatan', 'Praesent tempor velit ac purus volutpat, eget pellentesque nulla ultrices. Mauris quis egestas magna', -7.784627412733075, 110.37994737135772, '21:4', '9:4'),
(17, 'Apotek Kimia Farma', 'Kesehatan', 'Praesent tempor velit ac purus volutpat, eget pellentesque nulla ultrices. Mauris quis egestas magna', -7.788152562644278, 110.37816133199483, '21:5', '9:5'),
(18, 'Night Club', 'Things To do', 'Praesent tempor velit ac purus volutpat, eget pellentesque nulla ultrices. Mauris quis egestas magna', -7.782392420106534, 110.38046688247898, '21:6', '16:6'),
(19, 'Hotel OYO 69', 'Hotel', 'Praesent tempor velit ac purus volutpat, eget pellentesque nulla ultrices. Mauris quis egestas magna', -7.782970379600932, 110.37648904563144, '21:7', '9:7'),
(20, 'Hotel POP! star', 'Hotel', 'Praesent tempor velit ac purus volutpat, eget pellentesque nulla ultrices. Mauris quis egestas magna', -7.781687217557004, 110.38147025429703, '21:7', '9:7');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `72210456`
--
ALTER TABLE `72210456`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `72210456`
--
ALTER TABLE `72210456`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
