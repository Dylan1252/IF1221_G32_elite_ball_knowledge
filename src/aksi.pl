% ============================================================
%  VALIDASI KARTU
% ============================================================

kartu_cocok(kartu(hitam, wild)) :- !.

kartu_cocok(kartu(hitam, wild_draw_four)) :- !.

kartu_cocok(kartu(W, _)) :-
    warna_aktif(WA),
    W = WA, !.

kartu_cocok(kartu(_, J)) :-
    discard_top(kartu(_, J)), !.

% ============================================================
%  VALIDASI WILD DRAW FOUR
% ============================================================

wdf_valid :-

    giliran_sekarang(Pemain),

    kartu_di_tangan(Pemain, Tangan),

    warna_aktif(WA),

    discard_top(kartu(_, JD)),

    \+ (
        member(K, Tangan),

        K \= kartu(hitam, wild_draw_four),

        K \= kartu(hitam, wild),

        (
            K = kartu(WA, _)
            ;
            K = kartu(_, JD)
        )
    ).

kartu_valid_untuk_dimainkan(
    kartu(hitam, wild_draw_four)
) :- !,

    (
        wdf_valid

        -> true

        ;

        write(
            'Tidak valid: masih ada kartu lain yang cocok.'
        ),
        nl,
        fail
    ).

kartu_valid_untuk_dimainkan(K) :-

    (
        kartu_cocok(K)

        -> true

        ;

        write(
            'Kartu tidak cocok dengan discard pile.'
        ),
        nl,
        fail
    ).

% ============================================================
%  SET WARNA AKTIF
% ============================================================

set_warna_aktif(W) :-

    retractall(warna_aktif(_)),

    assertz(warna_aktif(W)).

% ============================================================
%  EFEK KARTU
% ============================================================

terapkan_efek(kartu(W, N)) :-

    angka(N), !,

    set_warna_aktif(W),

    pindah_giliran.

terapkan_efek(kartu(W, skip)) :- !,

    set_warna_aktif(W),

    pindah_giliran_skip.

terapkan_efek(kartu(W, reverse)) :- !,

    set_warna_aktif(W),

    arah_giliran(Arah),

    retract(arah_giliran(Arah)),

    (
        Arah = kanan

        -> ArahBaru = kiri

        ;

        ArahBaru = kanan
    ),

    assertz(arah_giliran(ArahBaru)),

    write('Arah permainan dibalik.'), nl,

    pindah_giliran.

terapkan_efek(kartu(W, draw_two)) :- !,

    set_warna_aktif(W),

    pemain_berikutnya(Berikutnya),

    ambil_n_kartu_untuk(Berikutnya, 2),

    format(
        '~w harus mengambil 2 kartu.~n',
        [Berikutnya]
    ),

    pindah_giliran_skip.

terapkan_efek(kartu(hitam, wild)) :- !,

    pilih_warna(Warna),

    set_warna_aktif(Warna),

    format(
        'Warna aktif sekarang: ~w.~n',
        [Warna]
    ),

    pindah_giliran.

terapkan_efek(kartu(hitam, wild_draw_four)) :- !,

    giliran_sekarang(Pemain),

    retractall(pemain_wdf(_)),

    assertz(pemain_wdf(Pemain)),

    pilih_warna(Warna),

    set_warna_aktif(Warna),

    format(
        'Warna aktif sekarang: ~w.~n',
        [Warna]
    ),

    retractall(efek_pending(_)),

    assertz(efek_pending(wild_draw_four)),

    pindah_giliran.

% ============================================================
%  MAINKAN KARTU
% ============================================================

mainkanKartu(N) :-

    giliran_sekarang(Pemain),

    (
        efek_pending(wild_draw_four)

        ->

        write(
            'Kartu wild draw four aktif. Gunakan tantang atau ambilKartu.'
        ),
        nl,
        fail

        ;

        true
    ),

    kartu_di_tangan(Pemain, Tangan),

    length(Tangan, Len),

    (
        (
            N < 1
            ;
            N > Len
        )

        ->

        format(
            'Nomor tidak valid. Pilih antara 1-~w.~n',
            [Len]
        ),

        fail

        ;

        true
    ),

    nth_element(N, Tangan, Kartu),

    (
        kartu_valid_untuk_dimainkan(Kartu)

        -> true

        ;

        fail
    ),

    hapus_ke_n(N, Tangan, TanganBaru),

    retract(
        kartu_di_tangan(
            Pemain,
            Tangan
        )
    ),

    assertz(
        kartu_di_tangan(
            Pemain,
            TanganBaru
        )
    ),

    retract(discard_top(_)),

    assertz(discard_top(Kartu)),

    (
        retract(status_uni(Pemain))

        -> true

        ;

        true
    ),

    format(
        '~w memainkan kartu: ',
        [Pemain]
    ),

    tulis_kartu(Kartu),

    write('.'), nl,

    (
        TanganBaru = []

        -> endGame

        ;

        terapkan_efek(Kartu)
    ).

% ============================================================
%  AMBIL KARTU
% ============================================================

ambilKartu :-

    giliran_sekarang(Pemain),

    (
        efek_pending(wild_draw_four)

        ->

        retractall(efek_pending(_)),
        retractall(pemain_wdf(_)),

        ambil_n_kartu_untuk(Pemain, 4),

        format(
            '~w mengambil 4 kartu.~n',
            [Pemain]
        ),

        pindah_giliran

        ;

        ambil_n_kartu_untuk(Pemain, 1),

        kartu_di_tangan(Pemain, TanganBaru),

        last(TanganBaru, KartuBaru),

        format(
            '~w mendapatkan kartu: ',
            [Pemain]
        ),

        tulis_kartu(KartuBaru),

        write('.'), nl,

        pindah_giliran
    ).

% ============================================================
%  TANTANG
% ============================================================

tantang :-

    giliran_sekarang(Penantang),

    (
        \+ efek_pending(wild_draw_four)

        ->

        write(
            'Tidak ada wild draw four yang bisa ditantang.'
        ),
        nl,
        fail

        ;

        true
    ),

    pemain_wdf(PemainWDF),

    write('Tantangan dilakukan!'), nl,

    format(
        'Memeriksa kartu ~w...~n',
        [PemainWDF]
    ),

    (
        pemain_punya_kartu_cocok_sebelum_wdf(PemainWDF)

        ->

        format(
            'Tantangan berhasil! ~w mendapatkan 4 kartu acak.~n',
            [PemainWDF]
        ),

        ambil_n_kartu_untuk(PemainWDF, 4),

        retractall(efek_pending(_)),
        retractall(pemain_wdf(_))

        ;

        format(
            'Tantangan gagal. ~w mendapatkan 6 kartu acak.~n',
            [Penantang]
        ),

        ambil_n_kartu_untuk(Penantang, 6),

        retractall(efek_pending(_)),
        retractall(pemain_wdf(_)),

        pindah_giliran
    ).

pemain_punya_kartu_cocok_sebelum_wdf(Pemain) :-

    kartu_di_tangan(Pemain, Tangan),

    warna_aktif(WA),

    discard_top(kartu(_, JD)),

    member(K, Tangan),

    K \= kartu(hitam, wild_draw_four),

    K \= kartu(hitam, wild),

    (
        K = kartu(WA, _)
        ;
        K = kartu(_, JD)
    ).

% ============================================================
%  UNI
% ============================================================

uni(N) :-

    giliran_sekarang(Pemain),

    (
        efek_pending(wild_draw_four)

        ->

        write(
            'Kartu wild draw four aktif. Gunakan tantang atau ambilKartu.'
        ),
        nl,
        fail

        ;

        true
    ),

    kartu_di_tangan(Pemain, Tangan),

    length(Tangan, Len),

    (
        (
            N < 1
            ;
            N > Len
        )

        ->

        format(
            'Nomor tidak valid. Pilih antara 1-~w.~n',
            [Len]
        ),

        fail

        ;

        true
    ),

    nth_element(N, Tangan, Kartu),

    LenSetelah is Len - 1,

    (
        LenSetelah =\= 1

        ->

        write(
            'Perintah uni tidak valid: kartu tidak akan tersisa satu.'
        ),
        nl,

        write(
            'Anda mendapatkan 1 kartu penalti.'
        ),
        nl,

        ambil_n_kartu_untuk(Pemain, 1),

        pindah_giliran,

        fail

        ;

        true
    ),

    (
        kartu_valid_untuk_dimainkan(Kartu)

        -> true

        ;

        fail
    ),

    hapus_ke_n(N, Tangan, TanganBaru),

    retract(
        kartu_di_tangan(
            Pemain,
            Tangan
        )
    ),

    assertz(
        kartu_di_tangan(
            Pemain,
            TanganBaru
        )
    ),

    retract(discard_top(_)),

    assertz(discard_top(Kartu)),

    (
        retract(status_uni(Pemain))

        -> true

        ;

        true
    ),

    assertz(status_uni(Pemain)),

    format(
        '~w memainkan kartu: ',
        [Pemain]
    ),

    tulis_kartu(Kartu),

    write('.'), nl,

    format(
        '~w menyerukan UNI!~n',
        [Pemain]
    ),

    (
        TanganBaru = []

        -> endGame

        ;

        terapkan_efek(Kartu)
    ).

% ============================================================
%  TANGKAP
% ============================================================

tangkap(NamaPemain) :-

    giliran_sekarang(Penangkap),

    kartu_di_tangan(
        NamaPemain,
        TanganTarget
    ),

    length(TanganTarget, JmlKartu),

    (
        (
            JmlKartu =:= 1,
            \+ status_uni(NamaPemain)
        )

        ->

        format(
            '~w tertangkap tidak menyerukan UNI.~n',
            [NamaPemain]
        ),

        format(
            '~w mendapatkan 2 kartu penalti.~n',
            [NamaPemain]
        ),

        ambil_n_kartu_untuk(
            NamaPemain,
            2
        ),

        pindah_giliran

        ;

        (
            JmlKartu =\= 1

            ->

            format(
                'Perintah tidak valid: ~w tidak memiliki satu kartu.~n',
                [NamaPemain]
            )

            ;

            format(
                'Perintah tidak valid: ~w sudah menyerukan UNI.~n',
                [NamaPemain]
            )
        ),

        format(
            '~w mendapatkan 1 kartu penalti.~n',
            [Penangkap]
        ),

        ambil_n_kartu_untuk(
            Penangkap,
            1
        ),

        pindah_giliran
    ).