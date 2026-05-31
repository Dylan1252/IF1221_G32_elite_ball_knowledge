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

semua_warna([merah, kuning, hijau, biru]).
semua_angka([0,1,2,3,4,5,6,7,8,9]).

angka(0).
angka(1).
angka(2).
angka(3).
angka(4).
angka(5).
angka(6).
angka(7).
angka(8).
angka(9).

:- consult('utilitas.pl').
:- consult('deck.pl').
:- consult('giliran.pl').
:- consult('validasi.pl').
:- consult('aksi.pl').
:- consult('game.pl').
:- consult('save_load.pl')

:- initialization(startGame).
