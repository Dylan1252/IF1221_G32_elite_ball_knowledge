% ============================================================
%  INPUT PEMAIN
% ============================================================

input_jumlah(Jumlah) :-

    write('Masukkan jumlah pemain: '),

    read(Input),

    (
        (
            Input >= 2,
            Input =< 4
        )

        ->

        Jumlah = Input

        ;

        write(
            'Mohon masukkan angka antara 2-4.'
        ),
        nl,

        minta_jumlah(Jumlah)
    ).

input_pemain(
    N,
    Max,
    [NamaAsli|Rest]
) :-

    N =< Max,

    format(
        'Masukkan nama pemain ~w: ',
        [N]
    ),

    read(NamaAsli),

    (
        pemain(NamaAsli)

        ->

        write(
            'Nama sudah digunakan. Masukkan nama lain: '
        ),
        nl,

        input_pemain(
            N,
            Max,
            [NamaAsli|Rest]
        )

        ;

        assertz(pemain(NamaAsli)),

        N1 is N + 1,

        input_pemain(
            N1,
            Max,
            Rest
        )
    ).

input_pemain(_, _, []).

% ============================================================
%  PILIH WARNA
% ============================================================

pilih_warna(Warna) :-

    write(
        'Pilih warna (merah/kuning/hijau/biru): '
    ),

    read(Input),

    (
        member(
            Input,
            [merah, kuning, hijau, biru]
        )

        ->

        Warna = Input

        ;

        write(
            'Warna tidak valid. Coba lagi.'
        ),
        nl,

        pilih_warna(Warna)
    ).

% ============================================================
%  LIHAT KARTU
% ============================================================

lihatKartu :-

    giliran_sekarang(Pemain),

    kartu_di_tangan(
        Pemain,
        Tangan
    ),

    write(
        'Berikut kartu yang anda miliki.'
    ),
    nl,

    tampilkan_kartu_bernomor(
        Tangan,
        1
    ).

% ============================================================
%  LIHAT COMMAND
% ============================================================

lihatCommand :-

    (
        efek_pending(wild_draw_four)

        ->

        write(
            'Aksi utama yang tersedia:'
        ),
        nl,

        write('1. tantang'), nl,
        write('2. ambilKartu'), nl

        ;

        write(
            'Aksi utama yang tersedia:'
        ),
        nl,

        write(
            '1. mainkanKartu(NomorUrut)'
        ),
        nl,

        write(
            '2. uni(NomorUrut)'
        ),
        nl,

        write('3. ambilKartu'), nl
    ),

    nl,

    write(
        'Aksi pendukung yang tersedia:'
    ),
    nl,

    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.

% ============================================================
%  CEK INFO
% ============================================================

cekInfo :-

    discard_top(DT),

    warna_aktif(WA),

    write('Kartu discard top: '),

    tulis_kartu(DT),

    write('.'), nl,

    format(
        'Warna aktif: ~w.~n',
        [WA]
    ),

    arah_giliran(Arah),

    format(
        'Arah giliran: ~w.~n',
        [Arah]
    ),

    urutan_pemain(Urutan),

    write('Urutan pemain: '),

    tampilkan_list(Urutan),

    nl,

    cetak_info_semua_pemain(
        Urutan,
        1
    ).

cetak_info_semua_pemain([], _).

cetak_info_semua_pemain(
    [P|Rest],
    N
) :-

    kartu_di_tangan(P, K),

    length(K, Jml),

    format(
        'Nama pemain ~w: ~w~n',
        [N, P]
    ),

    format(
        'Jumlah kartu : ~w~n~n',
        [Jml]
    ),

    N1 is N + 1,

    cetak_info_semua_pemain(
        Rest,
        N1
    ).