FasdUAS 1.101.10   ��   ��    k             l     ��������  ��  ��        l     �� 	 
��   	 � }Launch x11 on the machine if the process isn't already running.  Wait to be sure it starts prior to starting the application.    
 �   � L a u n c h   x 1 1   o n   t h e   m a c h i n e   i f   t h e   p r o c e s s   i s n ' t   a l r e a d y   r u n n i n g .     W a i t   t o   b e   s u r e   i t   s t a r t s   p r i o r   t o   s t a r t i n g   t h e   a p p l i c a t i o n .      l     ��������  ��  ��        i         I      �������� 0 	launchx11 	LaunchX11��  ��    k     �       r         l     ����  I    �� ��
�� .sysoexecTEXT���     TEXT  m        �   
 i d   - u��  ��  ��    o      ���� 0 userid userID      r        b         m    	 ! ! � " " 8 l s   - l n   / t m p / . X 1 1 - u n i x |   g r e p     o   	 
���� 0 userid userID  o      ���� 0 
displaydir 
Displaydir   # $ # l   ��������  ��  ��   $  % & % O    � ' ( ' Z    � ) *���� ) l    +���� + H     , , E     - . - l    /���� / c     0 1 0 n     2 3 2 1    ��
�� 
pnam 3 2   ��
�� 
prcs 1 m    ��
�� 
list��  ��   . m     4 4 � 5 5  X 1 1��  ��   * k    � 6 6  7 8 7 I   $�� 9��
�� .ascrnoop****      � **** 9 m      : :�                                                                                  x11a   alis    b  Das Hardendriven           ��C�H+   ӓX11.app                                                         fM�d��        ����  	                	Utilities     �Ϙ      �d��     ӓ    /Das Hardendriven:Applications:Utilities:X11.app     X 1 1 . a p p  "  D a s   H a r d e n d r i v e n  Applications/Utilities/X11.app  / ��  ��   8  ; < ; l  % %��������  ��  ��   <  = > = r   % ( ? @ ? m   % & A A � B B   @ o      ���� 0 results   >  C�� C Q   ) � D E F D k   , { G G  H I H r   , / J K J m   , -����  K o      ���� 0 x   I  L M L l  0 0�� N O��   N : 4 Timeout after 30 seconds in case there's a problem.    O � P P h   T i m e o u t   a f t e r   3 0   s e c o n d s   i n   c a s e   t h e r e ' s   a   p r o b l e m . M  Q R Q W   0 d S T S k   @ _ U U  V W V Q   @ S X Y�� X r   C J Z [ Z I  C H�� \��
�� .sysoexecTEXT���     TEXT \ o   C D���� 0 
displaydir 
Displaydir��   [ l      ]���� ] o      ���� 0 results  ��  ��   Y R      ������
�� .ascrerr ****      � ****��  ��  ��   W  ^ _ ^ r   T Y ` a ` [   T W b c b o   T U���� 0 x   c m   U V����  a o      ���� 0 x   _  d�� d I  Z _�� e��
�� .sysodelanull��� ��� nmbr e m   Z [���� ��  ��   T G   4 ? f g f l  4 7 h���� h >   4 7 i j i o   4 5���� 0 results   j m   5 6 k k � l l  ��  ��   g l  : = m���� m ?   : = n o n o   : ;���� 0 x   o m   ; <���� ��  ��   R  p q p Z  e y r s���� r ?  e h t u t o   e f���� 0 x   u m   f g����  s R   k u���� v
�� .ascrerr ****      � ****��   v �� w��
�� 
errn w m   o r�������  ��  ��   q  x�� x l  z z��������  ��  ��  ��   E R      ���� y
�� .ascrerr ****      � ****��   y �� z��
�� 
errn z m      �������   F k   � � { {  | } | I  � �������
�� .miscactvnull��� ��� null��  ��   }  ~�� ~ I  � ��� ��
�� .sysodlogaskr        TEXT  m   � � � � � � � � U n a b l e   t o   o b t a i n   d i s p l a y   v a r i a b l e   f r o m   / t m p / . X 1 1 - u n i x .     P l e a s e   m a k e   s u r e   y o u r   X 1 1   e n v i r o n m e n t   i s   s t a r t i n g   p r o p e r l y .��  ��  ��  ��  ��   ( m     � ��                                                                                  MACS   alis    ~  Das Hardendriven           ��C�H+   ��
Finder.app                                                      ���d��        ����  	                CoreServices    �Ϙ      �d��     �� 3� 3�  7Das Hardendriven:System:Library:CoreServices:Finder.app    
 F i n d e r . a p p  "  D a s   H a r d e n d r i v e n  &System/Library/CoreServices/Finder.app  / ��   &  � � � l  � ���������  ��  ��   �  ��� � L   � � � � m   � �����  ��     � � � l     ��������  ��  ��   �  � � � l     ��������  ��  ��   �  � � � l     �� � ���   � 9 3 Look at the socket number to determine the display    � � � � f   L o o k   a t   t h e   s o c k e t   n u m b e r   t o   d e t e r m i n e   t h e   d i s p l a y �  � � � i     � � � I      �������� 0 getdisplaynum GetDisplayNum��  ��   � k     5 � �  � � � r      � � � I    �� ���
�� .sysoexecTEXT���     TEXT � m      � � � � �  e c h o   $ D I S P L A Y��   � o      ���� 0 
displayenv 
displayEnv �  � � � l   ��������  ��  ��   �  ��� � Z    5 � ��� � � =    � � � o    	���� 0 
displayenv 
displayEnv � m   	 
 � � � � �   � k    0 � �  � � � r     � � � l    ����� � I   �� ���
�� .sysoexecTEXT���     TEXT � m     � � � � �  i d   - u   &��  ��  ��   � o      ���� 0 userid userID �  � � � r     � � � b     � � � b     � � � m     � � � � � : ` l s   - l n   / t m p / . X 1 1 - u n i x |   g r e p   � o    ���� 0 userid userID � m     � � � � �  ` � o      ���� 0 
displaydir 
Displaydir �  � � � l   ��������  ��  ��   �  � � � l   �� � ���   � ' ! Get Socket number to set DISPLAY    � � � � B   G e t   S o c k e t   n u m b e r   t o   s e t   D I S P L A Y �  � � � r    % � � � b    # � � � b    ! � � � m     � � � � �  b b b = � o     ���� 0 
displaydir 
Displaydir � m   ! " � � � � � ( ;   e c h o   $ { b b b / * X / : } . 0 � o      ���� 0 	socketcmd 	SocketCmd �  � � � r   & - � � � I  & +�� ���
�� .sysoexecTEXT���     TEXT � o   & '���� 0 	socketcmd 	SocketCmd��   � o      �� 0 
displaynum 
DisplayNum �  ��~ � L   . 0 � � o   . /�}�} 0 
displaynum 
DisplayNum�~  ��   � L   3 5 � � o   3 4�|�| 0 
displayenv 
displayEnv��   �  � � � l     �{�z�y�{  �z  �y   �  � � � l     �x�w�v�x  �w  �v   �  � � � l     �u � ��u   � A ; Sets up the DISPLAY and SHELL environment for ENVI and IDL    � � � � v   S e t s   u p   t h e   D I S P L A Y   a n d   S H E L L   e n v i r o n m e n t   f o r   E N V I   a n d   I D L �  ��t � i     � � � I      �s ��r�s $0 environmentsetup EnvironmentSetup �  ��q � o      �p�p 0 idldirfolder IDLDirFolder�q  �r   � k    � � �  � � � l     �o�n�m�o  �n  �m   �  � � � p       � � �l�k�l 0 fullsetupcmd fullSetupCmd�k   �  � � � p       � � �j�i�j 0 
displaycmd 
DisplayCmd�i   �  � � � p       � � �h�g�h 0 shellcmd shellCmd�g   �  � � � l     �f�e�d�f  �e  �d   �  � � � r      � � � m     �c
�c 
TEXT � o      �b�b 0 fullsetupcmd fullSetupCmd �  � � � r     � � � m    �a
�a 
TEXT � o      �`�` 0 
displaycmd 
DisplayCmd �  � � � r     � � � m    	�_
�_ 
TEXT � o      �^�^ 0 shellcmd shellCmd �  � � � r       m    �]
�] 
TEXT o      �\�\ 0 	idldircmd 	IDLDirCmd �  r     m    �[
�[ 
TEXT o      �Z�Z 0 	setupfile 	setupFile  r    	 m    

 � 
 e m p t y	 o      �Y�Y 0 setupcmd setupCmd  l   �X�W�V�X  �W  �V    r     I    �U�T�S�U 0 getdisplaynum GetDisplayNum�T  �S   o      �R�R 0 
displaynum 
DisplayNum  l     �Q�P�O�Q  �P  �O    l     �N�N     Use the users' shell    � *   U s e   t h e   u s e r s '   s h e l l  r     ' I    %�M�L
�M .sysoexecTEXT���     TEXT m     ! �  e c h o   $ S H E L L�L   o      �K�K 0 shellenv    !  r   ( -"#" b   ( +$%$ o   ( )�J�J 0 shellenv  % m   ) *&& �''    - c  # o      �I�I 0 shellcmd shellCmd! ()( l  . .�H�G�F�H  �G  �F  ) *+* l  . .�E,-�E  , J DDetermine the shell and set up to source init file only if it exists   - �.. � D e t e r m i n e   t h e   s h e l l   a n d   s e t   u p   t o   s o u r c e   i n i t   f i l e   o n l y   i f   i t   e x i s t s+ /0/ Z   .W12341 E   . 1565 o   . /�D�D 0 shellenv  6 m   / 077 �88  b a s h2 k   4 W99 :;: r   4 9<=< b   4 7>?> m   4 5@@ �AA  e x p o r t   D I S P L A Y =? o   5 6�C�C 0 
displaynum 
DisplayNum= o      �B�B 0 
displaycmd 
DisplayCmd; BCB r   : ?DED b   : =FGF m   : ;HH �II  e x p o r t   I D L _ D I R =G o   ; <�A�A 0 idldirfolder IDLDirFolderE o      �@�@ 0 	idldircmd 	IDLDirCmdC JKJ r   @ GLML I  @ E�?N�>
�? .sysoexecTEXT���     TEXTN m   @ AOO �PP H f i n d   $ H O M E   - m a x d e p t h   1   - n a m e   . b a s h r c�>  M o      �=�= 0 	setupfile 	setupFileK QRQ Z   H UST�<�;S E   H KUVU o   H I�:�: 0 	setupfile 	setupFileV m   I JWW �XX  . b a s h r cT r   N QYZY m   N O[[ �\\  .   ~ / . b a s h r cZ o      �9�9 0 setupcmd setupCmd�<  �;  R ]�8] l  V V�7^_�7  ^   tcsh	   _ �``    t c s h 	�8  3 aba E   Z ]cdc o   Z [�6�6 0 shellenv  d m   [ \ee �ff  t c s hb ghg k   ` �ii jkj r   ` glml b   ` enon m   ` cpp �qq  s e t e n v   D I S P L A Y  o o   c d�5�5 0 
displaynum 
DisplayNumm o      �4�4 0 
displaycmd 
DisplayCmdk rsr r   h otut b   h mvwv m   h kxx �yy  s e t e n v   I D L _ D I R  w o   k l�3�3 0 idldirfolder IDLDirFolderu o      �2�2 0 	idldircmd 	IDLDirCmds z{z r   p y|}| I  p w�1~�0
�1 .sysoexecTEXT���     TEXT~ m   p s ��� H f i n d   $ H O M E   - m a x d e p t h   1   - n a m e   . t c s h r c�0  } o      �/�/ 0 	setupfile 	setupFile{ ��� Z   z ����.�� E   z ��� o   z {�-�- 0 	setupfile 	setupFile� m   { ~�� ���  . t c s h r c� r   � ���� m   � ��� ���   s o u r c e   ~ / . t c s h r c� o      �,�, 0 setupcmd setupCmd�.  � k   � ��� ��� r   � ���� I  � ��+��*
�+ .sysoexecTEXT���     TEXT� m   � ��� ��� F f i n d   $ H O M E   - m a x d e p t h   1   - n a m e   . c s h r c�*  � o      �)�) 0 	setupfile 	setupFile� ��� Z   � ����(�'� E   � ���� o   � ��&�& 0 	setupfile 	setupFile� m   � ��� ���  . c s h r c� r   � ���� m   � ��� ���  s o u r c e   ~ / . c s h r c� o      �%�% 0 setupcmd setupCmd�(  �'  � ��$� l  � ��#�"�!�#  �"  �!  �$  � �� � l  � �����  � 	 csh   � ���  c s h�   h ��� E   � ���� o   � ��� 0 shellenv  � m   � ��� ���  / c s h� ��� k   � ��� ��� r   � ���� b   � ���� m   � ��� ���  s e t e n v   D I S P L A Y  � o   � ��� 0 
displaynum 
DisplayNum� o      �� 0 
displaycmd 
DisplayCmd� ��� r   � ���� b   � ���� m   � ��� ���  s e t e n v   I D L _ D I R  � o   � ��� 0 idldirfolder IDLDirFolder� o      �� 0 	idldircmd 	IDLDirCmd� ��� r   � ���� I  � ����
� .sysoexecTEXT���     TEXT� m   � ��� ��� F f i n d   $ H O M E   - m a x d e p t h   1   - n a m e   . c s h r c�  � o      �� 0 	setupfile 	setupFile� ��� Z   � ������ E   � ���� o   � ��� 0 	setupfile 	setupFile� m   � ��� ���  . c s h r c� r   � ���� m   � ��� ���  s o u r c e   ~ / . c s h r c� o      �� 0 setupcmd setupCmd�  �  � ��� l  � �����  �  
 sh or zsh   � ���    s h   o r   z s h�  � ��� G   � ���� l  � ����� E   � ���� o   � ��� 0 shellenv  � m   � ��� ���  / s h�  �  � l  � ����� E   � ���� o   � ��� 0 shellenv  � m   � ��� ���  / z s h�  �  � ��
� k   �#�� ��� r   � ���� b   � ���� m   � ��� ���  e x p o r t   D I S P L A Y =� o   � ��	�	 0 
displaynum 
DisplayNum� o      �� 0 
displaycmd 
DisplayCmd� ��� r   ��� b   ��� m   �� ���  e x p o r t   I D L _ D I R =� o  �� 0 idldirfolder IDLDirFolder� o      �� 0 	idldircmd 	IDLDirCmd� ��� r  ��� I ���
� .sysoexecTEXT���     TEXT� m  �� ��� J f i n d   $ H O M E   - m a x d e p t h   1   - n a m e   . p r o f i l e�  � o      �� 0 	setupfile 	setupFile� ��� Z  #� �� � E   o  ���� 0 	setupfile 	setupFile m   �  . p r o f i l e  r   m   �  .   ~ / . p r o f i l e o      ���� 0 setupcmd setupCmd�  �   �  �
  4 l &W	
	 k  &W  r  &+ m  &) �  / b i n / b a s h   - c   o      ���� 0 shellcmd shellCmd  r  ,3 b  ,1 m  ,/ �  e x p o r t   D I S P L A Y = o  /0���� 0 
displaynum 
DisplayNum o      ���� 0 
displaycmd 
DisplayCmd  r  4; b  49  m  47!! �""  e x p o r t   I D L _ D I R =  o  78���� 0 idldirfolder IDLDirFolder o      ���� 0 	idldircmd 	IDLDirCmd #$# r  <E%&% I <C��'��
�� .sysoexecTEXT���     TEXT' m  <?(( �)) H f i n d   $ H O M E   - m a x d e p t h   1   - n a m e   . b a s h r c��  & o      ���� 0 	setupfile 	setupFile$ *��* Z  FW+,����+ E  FK-.- o  FG���� 0 	setupfile 	setupFile. m  GJ// �00  . b a s h r c, r  NS121 m  NQ33 �44  .   ~ / . b a s h r c2 o      ���� 0 setupcmd setupCmd��  ��  ��  
 , & Default to use bash if not recognized    �55 L   D e f a u l t   t o   u s e   b a s h   i f   n o t   r e c o g n i z e d0 676 l XX��������  ��  ��  7 898 l XX��:;��  : C = Create the setup command.  Only add in the user's init setup   ; �<< z   C r e a t e   t h e   s e t u p   c o m m a n d .     O n l y   a d d   i n   t h e   u s e r ' s   i n i t   s e t u p9 =>= l XX��?@��  ?   if it was present   @ �AA $   i f   i t   w a s   p r e s e n t> BCB l XX��������  ��  ��  C DED Z  XoFG��HF > X]IJI o  XY���� 0 setupcmd setupCmdJ m  Y\KK �LL 
 e m p t yG r  `iMNM b  `gOPO b  `eQRQ o  `a���� 0 setupcmd setupCmdR m  adSS �TT  ;  P o  ef���� 0 	idldircmd 	IDLDirCmdN o      ���� 0 fullsetupcmd fullSetupCmd��  H r  loUVU o  lm���� 0 	idldircmd 	IDLDirCmdV o      ���� 0 fullsetupcmd fullSetupCmdE WXW l pp��������  ��  ��  X YZY Z  p�[\��][ G  p�^_^ D  pu`a` o  pq���� 0 shellenv  a m  qtbb �cc  / c s h_ D  x}ded o  xy���� 0 shellenv  e m  y|ff �gg 
 / t c s h\ r  ��hih b  ��jkj m  ��ll �mm . u n s e t e n v   G L _ R E S O U R C E S ;  k o  ������ 0 fullsetupcmd fullSetupCmdi o      ���� 0 fullsetupcmd fullSetupCmd��  ] r  ��non b  ��pqp m  ��rr �ss ( u n s e t   G L _ R E S O U R C E S ;  q o  ������ 0 fullsetupcmd fullSetupCmdo o      ���� 0 fullsetupcmd fullSetupCmdZ tut l ����������  ��  ��  u v��v l ����������  ��  ��  ��  �t       ��wxyz��  w �������� 0 	launchx11 	LaunchX11�� 0 getdisplaynum GetDisplayNum�� $0 environmentsetup EnvironmentSetupx �� ����{|���� 0 	launchx11 	LaunchX11��  ��  { ���������� 0 userid userID�� 0 
displaydir 
Displaydir�� 0 results  �� 0 x  |  �� ! ������� 4 :�� A k��������������}�� ���
�� .sysoexecTEXT���     TEXT
�� 
prcs
�� 
pnam
�� 
list
�� .ascrnoop****      � ****�� 
�� 
bool��  ��  
�� .sysodelanull��� ��� nmbr
�� 
errn���} ������
�� 
errn�����  
�� .miscactvnull��� ��� null
�� .sysodlogaskr        TEXT�� ��j E�O�%E�O� �*�-�,�&� v�j 	O�E�O TkE�O 3h��
 ���& �j E�W X  hO�kE�Okj [OY��O�� )a a lhY hOPW X  *j Oa j Y hUOjy �� �����~���� 0 getdisplaynum GetDisplayNum��  ��  ~ ������������ 0 
displayenv 
displayEnv�� 0 userid userID�� 0 
displaydir 
Displaydir�� 0 	socketcmd 	SocketCmd�� 0 
displaynum 
DisplayNum  ��� � � � � � �
�� .sysoexecTEXT���     TEXT�� 6�j E�O��  '�j E�O�%�%E�O�%�%E�O�j E�O�Y �z �� ����������� $0 environmentsetup EnvironmentSetup�� ����� �  ���� 0 idldirfolder IDLDirFolder��  � �������������� 0 idldirfolder IDLDirFolder�� 0 	idldircmd 	IDLDirCmd�� 0 	setupfile 	setupFile�� 0 setupcmd setupCmd�� 0 
displaynum 
DisplayNum�� 0 shellenv  � 2��������
����&7@HOW[epx������������������!(/3KSbflr
�� 
TEXT�� 0 fullsetupcmd fullSetupCmd�� 0 
displaycmd 
DisplayCmd�� 0 shellcmd shellCmd�� 0 getdisplaynum GetDisplayNum
�� .sysoexecTEXT���     TEXT
�� 
bool����E�O�E�O�E�O�E�O�E�O�E�O*j+ E�O�j E�O��%E�O�� (�%E�O�%E�O�j E�O�� �E�Y hOPY ��� Na �%E�Oa �%E�Oa j E�O�a  
a E�Y a j E�O�a  
a E�Y hOPOPY ��a  2a �%E�Oa �%E�Oa j E�O�a  
a E�Y hOPY u�a 
 �a a  & 0a !�%E�Oa "�%E�Oa #j E�O�a $ 
a %E�Y hY 3a &E�Oa '�%E�Oa (�%E�Oa )j E�O�a * 
a +E�Y hO�a , �a -%�%E�Y �E�O�a .
 �a /a  & a 0�%E�Y 	a 1�%E�OPascr  ��ޭ