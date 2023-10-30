; Luca Jacentink Gonçalves
; Sistemas embarcados turma x
segment code
..start:
            mov         ax,data
            mov         ds,ax
            mov         ax,stack
            mov         ss,ax
            mov         sp,stacktop

; salvar modo corrente de video(vendo como est� o modo de video da maquina)
            mov         ah,0Fh
            int         10h
            mov         [modo_anterior],al   

; alterar modo de video para gr�fico 640x480 16 cores
        mov         al,12h
        mov         ah,0
        int         10h

;desenhar retas

     

        mov     byte[cor],branco_intenso    ;raquete
        mov     ax, 600
        push        ax
        mov     ax, word[x_porta_a]
        push        ax
        mov     ax, 600
        push        ax
        mov     ax, word[x_porta_b]
        push        ax
        call        line

        mov     byte[cor],branco_intenso    ;linha cabeçalho
        mov     ax, 0
        push        ax
        mov     ax, 430
        push        ax
        mov     ax, 640
        push        ax
        mov     ax, 430
        push        ax
        call        line 

        
;desenha circulos 
        mov     byte[cor],cyan_claro  ;cabeça
        mov     ax,word[px]
        push        ax
        mov     ax,word[py]
        push        ax
        mov     ax,10
        push        ax
        call    full_circle
;cabeçalho
    mov     cx,56			;numero de caracteres
    mov     bx,0
    mov     dh,1			;linha 0-29
    mov     dl,3 			;coluna 0-79
	mov	    byte[cor],branco

escreve1:
	call    cursor
    mov     al,[bx+mensagem1]
	call    caracter
    inc     bx	                ;proximo caracter
	inc 	dl	                ;avanca a coluna
    loop    escreve1

    mov     cx,56			;numero de caracteres
    mov     bx,0
    mov     dh,2			;linha 0-29
    mov     dl,3			;coluna 0-79
	mov	   byte[cor],branco
escreve2:
call    cursor
    mov     al,[bx+mensagem2]
	call    caracter
    inc     bx	                ;proximo caracter
	inc  	dl	                ;avanca a coluna
    loop    escreve2
	mov	   byte[cor],branco




velocidade_mais:
        mov bx, 10
        mov [v_barra], bx
        call continua

velocidade_menos:
        mov bx, -10
        mov [v_barra], bx
        call continua
redesenharetangulocima:

        mov     byte[cor],preto    ;a
        mov     ax, 600
        push        ax
        mov     ax, word[x_porta_a]
        push        ax
        mov     ax, 600
        push        ax
        mov     ax, word[x_porta_b]
        push        ax
        call        line
        mov bx, 418
        cmp [x_porta_a], bx
        jle velocidade_mais
        call continua
     
redesenharetangulobaixo:

        mov     byte[cor],preto    ;a
        mov     ax, 600
        push        ax
        mov     ax, word[x_porta_a]
        push        ax
        mov     ax, 600
        push        ax
        mov     ax, word[x_porta_b]
        push        ax
        call        line
        mov bx, 11
        cmp [x_porta_b], bx
        jge velocidade_menos
        call continua


diminuivelocidade:
        call calcula_modulo
        cmp ax, 8
        jge divide
        call continua
aumentavelocidade:
        call calcula_modulo
        cmp ax, 24
        jle multiplica
        call continua

        
testa_tecla:
        mov ah, 08H ;Ler caracter da STDIN
        int 21H
        cmp al, 'c' ;
        jz redesenharetangulocima
        cmp al, 'b'
        jz redesenharetangulobaixo
        cmp al, 's'
        jz sai
        cmp al, 'm'
        jz diminuivelocidade
        cmp al, 'p'
        jz aumentavelocidade
divide:
        push ax

        mov ax, [vx]     ; Carrega o valor de vx em ax
        sar ax, 1        ; Divide ax por 2 (shift right)
        mov [vx], ax     ; Armazena o resultado de volta em vx

        mov ax, [vy]     ; Carrega o valor de vy em ax
        sar ax, 1        ; Divide ax por 2 (shift right)
        mov [vy], ax     ; Armazena o resultado de volta em vy

        pop ax

multiplica:
        push ax
        mov ax, 2
        mul word[vx]
        mov word[vx],ax

        mov ax, 2
        mul word[vy]
        mov word[vy],ax
        pop ax
        call continua


sai:
        mov ah,0 ; set video mode
        mov al,[modo_anterior] ; recupera o modo anterior
        int 10h
        mov ax,4c00h
        int 21h

del1:  
        mov bx, 0
        mov [v_barra], bx
        mov ah, 0bh    ;BIOS.TestKey
        int 21h
        cmp al, 0
        jne testa_tecla

        mov bx, 620
        cmp [px], bx
        jge moveesquerda

        mov bx, 20
        cmp [px], bx
        jle movedireita


        mov bx, 400
        cmp [py], bx
        jge movebaixo

        mov bx, 25
        cmp [py], bx
        jle movecima

       

        mov bx, 600
        cmp [px], bx
        je compara_cima
        call continua  

moveesquerda:
    neg word [vx]
    call continua

movedireita:
    neg word [vx] 
    call continua

movebaixo:
    neg word [vy]
    call continua
movecima:
    neg word [vy]
    call continua
    
compara_cima:
        mov bx, [x_porta_a]
        cmp [py], bx
        jle compara_baixo
        call continua
compara_baixo:
        mov bx, [x_porta_b]
        cmp [py], bx
        jge moveesquerda
        call continua
calcula_modulo:
    mov ax, [vx]    ; Carrega o valor de vx em ax
    test ax, ax     ; Testa o sinal do valor em ax
    jns skip_abs    ; Pula para skip_abs se o valor for não-negativo
    neg ax          ; Inverte o sinal do valor em ax
skip_abs:
    ret
apagacirculo:
        mov     byte[cor],preto ;cabe�a
        mov     ax,[px]
        push        ax
        mov     ax,[py]
        push        ax
        mov     ax,10
        push        ax
        call    full_circle
        mov bx, [vx]
        add [px], bx
        mov bx, [vy]
        add [py], bx
        mov     byte[cor],cyan_claro    ;cabe�a
        mov     ax,[px]
        push        ax
        mov     ax,[py]
        push        ax
        mov     ax,10
        push        ax
        call    full_circle
delay: ; Esteja atento pois talvez seja importante salvar contexto (no caso, CX, o que NÃO foi feito aqui).
        mov ax,0
        mov ah, 86h    ; Função 86h - Esperar por um período
        mov cx, [tempo] ; Carregue o tempo desejado em CX
        int 15h        ; Chame a interrupção 0x15
        ret
continua:
        call delay
        call apagacirculo
        mov bx, [v_barra]
        add [x_porta_a], bx
        add [x_porta_b], bx
        mov     byte[cor],branco_intenso    ;a
        mov     ax, 600
        push        ax
        mov     ax, word[x_porta_a]
        push        ax
        mov     ax, 600
        push        ax
        mov     ax, word[x_porta_b]
        push        ax
        call        line 
        pop cx
        call del1 
        loop continua 
        ret

escrevepontosluca:
call setapontosluca
call    cursor
    mov     al,[bx+PontuacaoLucastr]
	call    caracter
    inc     bx	                ;proximo caracter
	inc  	dl	                ;avanca a coluna

    loop    escrevepontosluca
    call moveesquerda

setapontosluca:
        mov ax, 0
        mov al, byte[PontuacaoLuca] 
        add al,30h                       
        mov [PontuacaoLucastr],al
        mov     cx,2		;numero de caracteres
        mov     bx,0
        mov     dh,1			;linha 0-29
        mov     dl,18			;coluna 0-79
        mov	   byte[cor],branco
escrevepontoscomp:
        call setapontoscomp
        call    cursor
        mov     al,[bx+PontuacaoComputadorstr]
                call    caracter
        inc     bx	                ;proximo caracter
                inc  	dl	                ;avanca a coluna
        loop    escrevepontoscomp   
setapontoscomp:
        mov     cx,2		;numero de caracteres
        mov     bx,0
        mov     dh,1			;linha 0-29
        mov     dl,23			;coluna 0-79
        mov	   byte[cor],branco

escrevevelocidade:
        call setastrvelocidade
        call    cursor
        mov     al,[bx+velocidadestr]
                call    caracter
        inc     bx	                ;proximo caracter
                inc  	dl	                ;avanca a coluna
        loop    escrevevelocidade  
setastrvelocidade:
        mov     cx,1		;numero de caracteres
        mov     bx,0
        mov     dh,2			;linha 0-29
        mov     dl,55			;coluna 0-79
        mov	   byte[cor],branco

;delay
;
;   função cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
        pushf
        push        ax
        push        bx
        push        cx
        push        dx
        push        si
        push        di
        push        bp
        mov         ah,2
        mov         bh,0
        int         10h
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret
;_____________________________________________________________________________
;
;   fun��o caracter escrito na posi��o do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
        pushf
        push        ax
        push        bx
        push        cx
        push        dx
        push        si
        push        di
        push        bp
            mov         ah,9
            mov         bh,0
            mov         cx,1
        mov         bl,[cor]
            int         10h
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        ret
;_____________________________________________________________________________
;
;   fun��o plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
        push        bp
        mov     bp,sp
        pushf
        push        ax
        push        bx
        push        cx
        push        dx
        push        si
        push        di
        mov         ah,0ch
        mov         al,[cor]
        mov         bh,0
        mov         dx,479
        sub     dx,[bp+4]
        mov         cx,[bp+6]
        int         10h
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        pop     bp
        ret     4
;_____________________________________________________________________________
;    fun��o circle
;    push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor
circle:
    push    bp
    mov     bp,sp
    pushf                        ;coloca os flags na pilha
    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di
    
    mov     ax,[bp+8]    ; resgata xc
    mov     bx,[bp+6]    ; resgata yc
    mov     cx,[bp+4]    ; resgata r
    
    mov     dx,bx   
    add     dx,cx       ;ponto extremo superior
    push    ax          
    push    dx
    call plot_xy
    
    mov     dx,bx
    sub     dx,cx       ;ponto extremo inferior
    push    ax          
    push    dx
    call plot_xy
    
    mov     dx,ax   
    add     dx,cx       ;ponto extremo direita
    push    dx          
    push    bx
    call plot_xy
    
    mov     dx,ax
    sub     dx,cx       ;ponto extremo esquerda
    push    dx          
    push    bx
    call plot_xy
        
    mov     di,cx
    sub     di,1     ;di=r-1
    mov     dx,0    ;dx ser� a vari�vel x. cx � a variavel y
    
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay:               ;loop
    mov     si,di
    cmp     si,0
    jg      inf       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
    mov     si,dx       ;o jl � importante porque trata-se de conta com sinal
    sal     si,1        ;multiplica por doi (shift arithmetic left)
    add     si,3
    add     di,si     ;nesse ponto d=d+2*dx+3
    inc     dx      ;incrementa dx
    jmp     plotar
inf:    
    mov     si,dx
    sub     si,cx       ;faz x - y (dx-cx), e salva em di 
    sal     si,1
    add     si,5
    add     di,si       ;nesse ponto d=d+2*(dx-cx)+5
    inc     dx      ;incrementa x (dx)
    dec     cx      ;decrementa y (cx)
    
plotar: 
    mov     si,dx
    add     si,ax
    push    si          ;coloca a abcisa x+xc na pilha
    mov     si,cx
    add     si,bx
    push    si          ;coloca a ordenada y+yc na pilha
    call plot_xy        ;toma conta do segundo octante
    mov     si,ax
    add     si,dx
    push    si          ;coloca a abcisa xc+x na pilha
    mov     si,bx
    sub     si,cx
    push    si          ;coloca a ordenada yc-y na pilha
    call plot_xy        ;toma conta do s�timo octante
    mov     si,ax
    add     si,cx
    push    si          ;coloca a abcisa xc+y na pilha
    mov     si,bx
    add     si,dx
    push    si          ;coloca a ordenada yc+x na pilha
    call plot_xy        ;toma conta do segundo octante
    mov     si,ax
    add     si,cx
    push    si          ;coloca a abcisa xc+y na pilha
    mov     si,bx
    sub     si,dx
    push    si          ;coloca a ordenada yc-x na pilha
    call plot_xy        ;toma conta do oitavo octante
    mov     si,ax
    sub     si,dx
    push    si          ;coloca a abcisa xc-x na pilha
    mov     si,bx
    add     si,cx
    push    si          ;coloca a ordenada yc+y na pilha
    call plot_xy        ;toma conta do terceiro octante
    mov     si,ax
    sub     si,dx
    push    si          ;coloca a abcisa xc-x na pilha
    mov     si,bx
    sub     si,cx
    push    si          ;coloca a ordenada yc-y na pilha
    call plot_xy        ;toma conta do sexto octante
    mov     si,ax
    sub     si,cx
    push    si          ;coloca a abcisa xc-y na pilha
    mov     si,bx
    sub     si,dx
    push    si          ;coloca a ordenada yc-x na pilha
    call plot_xy        ;toma conta do quinto octante
    mov     si,ax
    sub     si,cx
    push    si          ;coloca a abcisa xc-y na pilha
    mov     si,bx
    add     si,dx
    push    si          ;coloca a ordenada yc-x na pilha
    call plot_xy        ;toma conta do quarto octante
    
    cmp     cx,dx
    jb      fim_circle  ;se cx (y) est� abaixo de dx (x), termina     
    jmp     stay        ;se cx (y) est� acima de dx (x), continua no loop
    
    
fim_circle:
    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    popf
    pop     bp
    ret     6
;-----------------------------------------------------------------------------
;    fun��o full_circle
;    push xc; push yc; push r; call full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor                    
full_circle:
    push    bp
    mov     bp,sp
    pushf                        ;coloca os flags na pilha
    push    ax
    push    bx
    push    cx
    push    dx
    push    si
    push    di

    mov     ax,[bp+8]    ; resgata xc
    mov     bx,[bp+6]    ; resgata yc
    mov     cx,[bp+4]    ; resgata r
    
    mov     si,bx
    sub     si,cx
    push    ax          ;coloca xc na pilha         
    push    si          ;coloca yc-r na pilha
    mov     si,bx
    add     si,cx
    push    ax      ;coloca xc na pilha
    push    si      ;coloca yc+r na pilha
    call line
    
        
    mov     di,cx
    sub     di,1     ;di=r-1
    mov     dx,0    ;dx ser� a vari�vel x. cx � a variavel y
    
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay_full:              ;loop
    mov     si,di
    cmp     si,0
    jg      inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
    mov     si,dx       ;o jl � importante porque trata-se de conta com sinal
    sal     si,1        ;multiplica por doi (shift arithmetic left)
    add     si,3
    add     di,si     ;nesse ponto d=d+2*dx+3
    inc     dx      ;incrementa dx
    jmp     plotar_full
inf_full:   
    mov     si,dx
    sub     si,cx       ;faz x - y (dx-cx), e salva em di 
    sal     si,1
    add     si,5
    add     di,si       ;nesse ponto d=d+2*(dx-cx)+5
    inc     dx      ;incrementa x (dx)
    dec     cx      ;decrementa y (cx)
    
plotar_full:    
    mov     si,ax
    add     si,cx
    push    si      ;coloca a abcisa y+xc na pilha          
    mov     si,bx
    sub     si,dx
    push    si      ;coloca a ordenada yc-x na pilha
    mov     si,ax
    add     si,cx
    push    si      ;coloca a abcisa y+xc na pilha  
    mov     si,bx
    add     si,dx
    push    si      ;coloca a ordenada yc+x na pilha    
    call    line
    
    mov     si,ax
    add     si,dx
    push    si      ;coloca a abcisa xc+x na pilha          
    mov     si,bx
    sub     si,cx
    push    si      ;coloca a ordenada yc-y na pilha
    mov     si,ax
    add     si,dx
    push    si      ;coloca a abcisa xc+x na pilha  
    mov     si,bx
    add     si,cx
    push    si      ;coloca a ordenada yc+y na pilha    
    call    line
    
    mov     si,ax
    sub     si,dx
    push    si      ;coloca a abcisa xc-x na pilha          
    mov     si,bx
    sub     si,cx
    push    si      ;coloca a ordenada yc-y na pilha
    mov     si,ax
    sub     si,dx
    push    si      ;coloca a abcisa xc-x na pilha  
    mov     si,bx
    add     si,cx
    push    si      ;coloca a ordenada yc+y na pilha    
    call    line
    
    mov     si,ax
    sub     si,cx
    push    si      ;coloca a abcisa xc-y na pilha          
    mov     si,bx
    sub     si,dx
    push    si      ;coloca a ordenada yc-x na pilha
    mov     si,ax
    sub     si,cx
    push    si      ;coloca a abcisa xc-y na pilha  
    mov     si,bx
    add     si,dx
    push    si      ;coloca a ordenada yc+x na pilha    
    call    line
    
    cmp     cx,dx
    jb      fim_full_circle  ;se cx (y) est� abaixo de dx (x), termina     
    jmp     stay_full       ;se cx (y) est� acima de dx (x), continua no loop
    
    
fim_full_circle:
    pop     di
    pop     si
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    popf
    pop     bp
    ret     6
;-----------------------------------------------------------------------------
;
;   fun��o line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
        push        bp
        mov     bp,sp
        pushf                        ;coloca os flags na pilha
        push        ax
        push        bx
        push        cx
        push        dx
        push        si
        push        di
        mov     ax,[bp+10]   ; resgata os valores das coordenadas
        mov     bx,[bp+8]    ; resgata os valores das coordenadas
        mov     cx,[bp+6]    ; resgata os valores das coordenadas
        mov     dx,[bp+4]    ; resgata os valores das coordenadas
        cmp     ax,cx
        je      line2
        jb      line1
        xchg        ax,cx
        xchg        bx,dx
        jmp     line1
line2:      ; deltax=0
        cmp     bx,dx  ;subtrai dx de bx
        jb      line3
        xchg        bx,dx        ;troca os valores de bx e dx entre eles
line3:  ; dx > bx
        push        ax
        push        bx
        call        plot_xy
        cmp     bx,dx
        jne     line31
        jmp     fim_line
line31:     inc     bx
        jmp     line3
;deltax <>0
line1:
; comparar m�dulos de deltax e deltay sabendo que cx>ax
    ; cx > ax
        push        cx
        sub     cx,ax
        mov     [deltax],cx
        pop     cx
        push        dx
        sub     dx,bx
        ja      line32
        neg     dx
line32:     
        mov     [deltay],dx
        pop     dx

        push        ax
        mov     ax,[deltax]
        cmp     ax,[deltay]
        pop     ax
        jb      line5

    ; cx > ax e deltax>deltay
        push        cx
        sub     cx,ax
        mov     [deltax],cx
        pop     cx
        push        dx
        sub     dx,bx
        mov     [deltay],dx
        pop     dx

        mov     si,ax
line4:
        push        ax
        push        dx
        push        si
        sub     si,ax   ;(x-x1)
        mov     ax,[deltay]
        imul        si
        mov     si,[deltax]     ;arredondar
        shr     si,1
; se numerador (DX)>0 soma se <0 subtrai
        cmp     dx,0
        jl      ar1
        add     ax,si
        adc     dx,0
        jmp     arc1
ar1:        sub     ax,si
        sbb     dx,0
arc1:
        idiv        word [deltax]
        add     ax,bx
        pop     si
        push        si
        push        ax
        call        plot_xy
        pop     dx
        pop     ax
        cmp     si,cx
        je      fim_line
        inc     si
        jmp     line4

line5:      cmp     bx,dx
        jb      line7
        xchg        ax,cx
        xchg        bx,dx
line7:
        push        cx
        sub     cx,ax
        mov     [deltax],cx
        pop     cx
        push        dx
        sub     dx,bx
        mov     [deltay],dx
        pop     dx



        mov     si,bx
line6:
        push        dx
        push        si
        push        ax
        sub     si,bx   ;(y-y1)
        mov     ax,[deltax]
        imul        si
        mov     si,[deltay]     ;arredondar
        shr     si,1
; se numerador (DX)>0 soma se <0 subtrai
        cmp     dx,0
        jl      ar2
        add     ax,si
        adc     dx,0
        jmp     arc2
ar2:        sub     ax,si
        sbb     dx,0
arc2:
        idiv        word [deltay]
        mov     di,ax
        pop     ax
        add     di,ax
        pop     si
        push        di
        push        si
        call        plot_xy
        pop     dx
        cmp     si,dx
        je      fim_line
        inc     si
        jmp     line6

fim_line:
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        pop     bp
        ret     8
;*******************************************************************
segment data

cor     db      branco_intenso

;   I R G B COR
;   0 0 0 0 preto
;   0 0 0 1 azul
;   0 0 1 0 verde
;   0 0 1 1 cyan
;   0 1 0 0 vermelho
;   0 1 0 1 magenta
;   0 1 1 0 marrom
;   0 1 1 1 branco
;   1 0 0 0 cinza
;   1 0 0 1 azul claro
;   1 0 1 0 verde claro
;   1 0 1 1 cyan claro
;   1 1 0 0 rosa
;   1 1 0 1 magenta claro
;   1 1 1 0 amarelo
;   1 1 1 1 branco intenso

preto       equ     0
azul        equ     1
verde       equ     2
cyan        equ     3
vermelho    equ     4
magenta     equ     5
marrom      equ     6
branco      equ     7
cinza       equ     8
azul_claro  equ     9
verde_claro equ     10
cyan_claro  equ     11
rosa        equ     12
magenta_claro   equ     13
amarelo     equ     14
branco_intenso  equ     15



modo_anterior   db      0
linha       dw          0
coluna      dw          0
deltax      dw      0
deltay      dw      0           
mensagem1           db      'Exercicio de Programacao de Sistemas Embarcados 1 2023/2'
mensagem2           db      'Luca Jacentink  00 x 00 Computador      Velocidade (1/3)'
PontuacaoLuca           dw      0
PontuacaoComputador     dw      0
PontuacaoComputadorstr db '0'
PontuacaoLucarstr db '0'
velocidadestr db '1'
velocidade      dw      1
tempo           dw      1
vx      dw      8
vy      dw      8
v_barra dw      0
px      dw      400
py      dw      240
x_porta_a dw 335
x_porta_b dw 285
;*************************************************************************
segment stack stack
            resb        512
stacktop:
