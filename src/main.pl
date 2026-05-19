:- dynamic(pemain/1).
:- dynamic(urutan_pemain/1).
:- dynamic(kartu_di_tangan/2).
:- dynamic(discard_top/1).
:- dynamic(giliran_sekarang/1).
:- dynamic(deck_kartu/1).
:- dynamic(arah_giliran/1).
:- dynamic(warna_aktif/1).
:- dynamic(efek_pending/1).
:- dynamic(pemain_wdf/1).
:- dynamic(status_uni/1).
 
:- consult(fakta).      % Fakta dasar: warna, angka
:- consult(utils).      % Utilitas list & tampilan
:- consult(deck).       % Pembuatan & manajemen deck
:- consult(giliran).    % Logika urutan & perpindahan giliran
:- consult(validasi).   % Validasi kartu & efek kartu
:- consult(aksi).       % Aksi utama & pendukung pemain
:- consult(game).       % Inisialisasi & akhir permainan

:- initialization(startGame).
