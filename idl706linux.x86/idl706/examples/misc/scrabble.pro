; $Id: //depot/idl/IDL_70/idldir/examples/misc/scrabble.pro#2 $
;
; Copyright (c) 1988-2008, ITT Visual Information Solutions. All
;       rights reserved.


function anagram, word  ;Return the anagram of a word.
    on_error,2                      ;Return to caller if an error occurs
    if strlen(word) gt 1 then begin
        w = byte(word)
        return, string(w[sort(w)])
    endif else return, word
end


function remove_dup,a   ;Remove elements in a with duplicate anagrams.
;
on_error,2              ;Return to caller if an error occurs
b = a
n = n_elements(a)
if n le 2 then return,b
for i=0,n-1 do a[i] = anagram(a[i]) ;Make into anagrams
a = a[sort(a)]      ;Sort it
j = 0
i = 1
while i lt n do begin   ;Remove identical entrys
    if a[i] ne a[j] then begin
        j = j+1
        a[j] = a[i]
        endif
    i = i+1
    endwhile
return, a[0:j]      ;Return result
end

function remainder, word, part  ;Return chars in word not contained in part.
;
; List of common suffixes:
;
on_error,2                              ;Return to caller if an error occurs
suf = ['ing','er','s','tion','ed','ist','ize','al']
if strlen(part) ge strlen(word) then return,"" ;Nothing left
w = byte(word)
p = byte(part)
for i=0,strlen(part)-1 do begin
    j = where(w eq p[i])
    w[j[0]] = 0
    endfor
a = anagram(string(w[where(w ne 0)]))   ;Remainder...

; Indicate possible suffix with upper case:
for i=0,n_elements(suf)-1 do begin
    if strpos(a,anagram(suf[i])) ge 0 then a = strupcase(a)
    end
return,a
end




function part_word, word, nchars    ;Forward definition for recursive fcn
on_error,2                              ;Return to caller if an error occurs
return,0
end

function part_word, word, nchars    ;Return all the sets of nchars letters
  ;in word, without regard to order.  nchars must be less than strlen(word).
  ;Even though it's not supposed to happen, this procedure is recursive.
  ;
on_error,2                      ;Return to caller if an error occurs
n = strlen(word)
if n lt nchars then return,result   ;Return undefined if nchars > length
if n eq nchars then begin   ; If getting all letters, return original
    rslt = strarr(1)
    rslt[0] = word
  endif else begin
;
    k = 1
    for i=nchars, n-1 do k = k * (i+1) ;Total # of elements required
    rslt = strarr(k)    ;Make result
    k = 0
    n2 = n-2
    b = byte(word)
    t = b[1:*]      ;Remove 1st char
    s = indgen(n)
    i = 0           ;Remove each character for n combinations
loop:       ;Avoid for loops for recursion
    w = string(t)       ;Back to string
    if nchars ne (n-1) then q = part_word(w, nchars) $ ;Get new combs
    else q = w
    rslt[k] = q         ;store in result
    k = k + n_elements(q)       ;Bump ptr
    t[i < n2] = b[i]    ;Substitute next. last doesnt matter
    i = i + 1
    if i lt n then goto, loop
  endelse
return, rslt
end



function find_word, word, lun  ;Find, using binary search technique,  the
; words with the same anagram as word.
;
;print,format="($, 1x,a)",word

common scrabble, ptr

on_error,2              ;Return to caller if an error occurs

w = anagram(word)   ;Get the word
;print,"Looking up ",word,", anagram = ",w

low = 0         ;low limit
high = n_elements(ptr)-1        ;High limit
a = ""
mid = (low + high) /2   ;midpoint

while (low le high) do begin    ;Loop
    mid = (low + high)/2    ;midpoint index
    point_lun, lun, ptr[mid] ;^ to proper line
    readf,lun, a        ;Read line
    w1 = strmid(a, 0, strpos(a," ")) ;Extract anagram
    if w1 eq w then begin   ;Found it, separate words.
        a = strmid(a,strpos(a," ")+1,1000)
        return,a    ;Got it
    endif         ;match
    if w1 lt w then low = mid + 1 $ ;move fwds
    else high = mid -1
endwhile
;print,"Couldn't find anagram for: ", word
return,""       ;Return null string for nothing
end


function head,str   ;Remove the head of str, return it.  blanks are
            ;delimiters.
on_error,2              ;Return to caller if an error occurs
i = strpos(str," ")
if i ge 0 then begin
    r=strmid(str,0,i)
    str = strmid(str,i+1,1000)
endif else begin
    r = str
    str = ""
endelse
return,r
end


pro make_anagram, lun   ;Make the anagram file

on_error,2              ;Return to caller if an error occurs
print, "Creating file anagrams.dat.  This will take about 5 minutes."
print,systime()

if !version.os_family ne 'unix' then $
    message, 'currently implemented for UNIX only.'

if lmgr(/demo) then $
    message, 'IDL is in timed demo mode. Cannot write anagrams.dat file.'

spawn, "wc /usr/dict/words", out
i = strpos(out[0],"\")  ;Remove leading line, might not work with all shells
out = strtrim(strmid(out[0],i+1,100),1) ;Also, remove leading blanks
wc = long(strmid(out,0,strpos(out," "))) ;Should be # of words
print, "Reading ",wc," words"


a = strarr(wc)      ;Make string array for all words
b = strarr(wc+1)    ;String array for anagrams
get_lun, lun1
openr,lun1,'/usr/dict/words'
readf,lun1,a        ;Read words
close,lun1
;
print,"Making anagrams."
for i=0L,wc-1 do begin
    c = strlowcase(a[i])    ;Cvt to lower
    a[i] = c
    if strlen(c) gt 1 then begin
        c = byte(c) ;Get into bytes, and sort by character
        b[i] = string(c[sort(c)]) ;back to string
    endif else b[i] = c
endfor
;
;   Now sort the anagram array b:
;
print,"Sorting anagrams."
c = sort(b) ;into lexical order
;
print,"Writing output."
close,lun
openw,lun,'anagrams.dat'
lc = 0L
ptr = lonarr(wc)

for i=1L, wc-1 do begin  ;Output list, merging words with same anagram
            ;Skip 1st element which is the null string.
    j = i+1
    q = b[c[i]] ;first word with same anagram
    while q eq b[c[j]] do j=j+1
    out = q     ;Make concatenated string
    for k = i,j-1 do out = out + " " + a[c[k]]
    i = j-1     ;Skip the ones we did.
    printf,lun,out
    q = fstat(lun)
    ptr[lc] = q.cur_ptr ;Save ^ in file
    lc = lc + 1
    endfor

ptr = ptr[0:lc-1]       ;Truncate pointer to proper length
save, file = 'anagrams_ptr.dat', ptr

print,"Done, wrote ",lc," lines."
print,systime()
close,lun
openr,lun,'anagrams.dat'    ;Re open to read
point_lun, lun, 0   ;Reset back to beginning

end



pro scrabble, word, double = doub, triple = trip, minchar = minchar
;+
; NAME:
;   SCRABBLE
;
; PURPOSE:
;   Solve Scrabble(R) puzzles.
;
; CATEGORY:
;   Games.
;
; CALLING SEQUENCE:
;   SCRABBLE, Word [, DOUB = Doub, TRIP = Trip, MINCHAR = Minchar]
;
; INPUTS:
;   WORD:   A string representing the letters in the rack.  This string
;       can be any length, although words of two characters or fewer
;       are not checked.
;
; KEYWORDS:
;   DOUBLE: The indices of any double-score letters in WORD where index
;       0 is the first letter.  Omit this keyword if there are no
;       double score letters.  This keyword can be set to a scalar
;       or an array if there is more than one double score letter.
;
;   TRIPLE: Indices of any triple-score letters in WORD where index
;       0 is the first letter.  Omit this keyword if ther are no
;       triple score letters.  This keyword can be set to a scalar
;       or an array if there is more than one triple score letter.
;
;      MINCHAR: The smallest number of characters to consider when matching.
;       The default is 4.
;
; OUTPUTS:
;   A list of possible words and their scores is output.
;
; EXAMPLE:
;   To work on a rack with the letters "aeimmtw", with the third
;   letter triple, enter:
;
;       SCRABBLE, "aeimmtw", TRIP=2
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   Uses the files anagrams.dat and anagrams_ptr.dat.  If these files
;   don't exist, they are created by the procedure make_anagram.
;
; RESTRICTIONS:
;   Doesn't consider all suffixes.  Uses only the words in
;   /usr/dict/words.  The remaining letters are printed after
;   the word that's found, sometimes making the suffix obvious.
;   For example, the word "AVIATOR" is not found because the root
;   word in /usr/dict/words is "AVIATE", and there is no "E" in
;   "AVIATOR".
;
;   Procedure make_anagram is implemented for UNIX only.
;   Thus, in general, SCRABBLE works only on UNIX.
;
; PROCEDURE:
;   Uses anagrams.  Misses some words in dictionary that end in common
;   suffixes such as "ing", "er", "ed", etc.
;
; MODIFICATION HISTORY:
;   DMS, Jan, 1988.
;-
;
common scrabble, ptr

on_error,2                      ;Return to caller if an error occurs

if n_elements(word) eq 0 then $
    message, 'requires a string argument.'

score = [1,3,3,2,1,4,2,4,1,8,5, $ ;a-k
    1,3,1,1,3,10,1,1,1,      $ ;l-t
    1,4,4,10,4,10 ]     ;u - z
nc = strlen(word)       ;Length of rack
word = strlowcase(word)     ;Cvt to lower case

weight = replicate(1,nc)    ;Make weights
if n_elements(doub) ne 0 then weight[doub] = 2 ;fill in double weights
if n_elements(trip) ne 0 then weight[trip] = 3

;
get_lun, lun    ;Get a unit number.
on_ioerror, no_anagram
openr,lun,'anagrams.dat'
goto, anagram_ok
;
no_anagram:     ;Anagram file doesn't exist.  Make it.
    make_anagram, lun
;
anagram_ok:
if n_elements(ptr) le 0 then restore,file='anagrams_ptr.dat'
;
;       Make the anagram of the string:
;

maxscore = 0
if n_elements(minchar) eq 0 then minchar = 4    ;Minimum #  of chars

for len = nc, minchar, -1 do begin  ;main loop
    a = part_word(word,len) ;Get len length combinations
    if n_elements(a) gt 0 then a = remove_dup(a) ;Get rid of duplications
    for i=0,n_elements(a)-1 do begin ;Process each combination
        q = find_word(a[i], lun) ;look up word in anagrams
        while strlen(q) gt 0 do begin    ;Anything there?
            w = head(q)
            s = fix(total(weight * score[byte(w)-97]))
            if strlen(w) ge 7 then s = s + 50
            w = w + " (" + remainder(word,w) + ")"
            print,"Found word: ",w,",  Score ",s
            if s ge maxscore then begin  ;Best score?
                maxscore = s
                result = w
            endif
        endwhile        ;strlen q
    endfor      ;n_elements a
endfor          ;for len

if maxscore ne 0 then begin
    if strpos(result," ") ge 7 then $
        print,'50 point bonus for using all 7 letters'
    print,"Final word: ",strupcase(result)," Score ",maxscore
endif else print,"Found no matches."

end
