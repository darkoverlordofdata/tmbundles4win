FasdUAS 1.101.10   ��   ��    k             l     �� ��    O I-------------------------------------------------------------------------       	  l     �� 
��   
 * $ Script to send text to destinations    	     l     ������  ��        l     �� ��    J D Takes two arguments.  The first one is a URL, and the second one is         l     �� ��    8 2 something of the form (newline-separated string):         l     �� ��               l     �� ��          Send to Quicksilver         l     �� ��          Open in Browser         l     �� ��    ( "     Paste to Colloquy: ##textmate          l     �� !��   ! #      Paste to Colloquy: allan       " # " l     �� $��   $ ( "     Paste to Adium: Allan Odgaard    #  % & % l     ������  ��   &  ' ( ' l     ������  ��   (  ) * ) i      + , + I     �� -��
�� .aevtoappnull  �   � **** - o      ���� 0 argv  ��   , k      . .  / 0 / r      1 2 1 n      3 4 3 4    �� 5
�� 
cobj 5 m    ����  4 o     ���� 0 argv   2 o      ���� 0 argurl argURL 0  6 7 6 r     8 9 8 n     : ; : 4    �� <
�� 
cobj < m   	 
����  ; o    ���� 0 argv   9 o      ���� "0 argdestinations argDestinations 7  = > = l   ������  ��   >  ?�� ? I    �� @���� .0 sendurltodestinations sendURLToDestinations @  A B A o    ���� 0 argurl argURL B  C�� C o    ���� "0 argdestinations argDestinations��  ��  ��   *  D E D l     ������  ��   E  F G F l     ������  ��   G  H I H i     J K J I      �� L���� .0 sendurltodestinations sendURLToDestinations L  M N M o      ���� 0 theurl theURL N  O�� O o      ���� "0 thedestinations theDestinations��  ��   K k    ( P P  Q R Q q       S S �� T�� 0 sep   T ������ 0 
thechannel 
theChannel��   R  U V U r      W X W m      Y Y  
    X o      ���� 0 sep   V  Z [ Z l   ������  ��   [  \ ] \ l   �� ^��   ^ H B convert theDestinations from a newline-delimited string to a list    ]  _ ` _ r     a b a I   �� c d�� 	0 split   c o    ���� "0 thedestinations theDestinations d �� e��
�� 
by   e o    ���� 0 sep  ��   b o      ���� "0 thedestinations theDestinations `  f g f l   ������  ��   g  h�� h X   ( i�� j i k   # k k  l m l r    # n o n c    ! p q p o    ���� 0 dest   q m     ��
�� 
TEXT o o      ���� 0 dest   m  r�� r Z   $# s t u�� s =  $ ' v w v o   $ %���� 0 dest   w m   % & x x  Send to Quicksilver    t k   * < y y  z { z O   * : | } | k   . 9 ~ ~   �  I  . 3������
�� .miscactvnull��� ��� null��  ��   �  ��� � r   4 9 � � � o   4 5���� 0 theurl theURL � 1   5 8��
�� 
sele��   } m   * + � ��null     ߀��  *Quicksilver.app �^� �c`����    }�P   )       �L(�]�����  ~daed   alis    T  Ladybird                   ���BH+    *Quicksilver.app                                                 k�"�#Q�        ����  	                Applications    ���"      �#5�      *  %Ladybird:Applications:Quicksilver.app      Q u i c k s i l v e r . a p p    L a d y b i r d  Applications/Quicksilver.app  / ��   {  ��� � l  ; ;������  ��  ��   u  � � � =  ? B � � � o   ? @���� 0 dest   � m   @ A � �  Open in Browser    �  � � � k   E Q � �  � � � O  E O � � � I  I N�� ���
�� .GURLGURLnull��� ��� TEXT � o   I J���� 0 theurl theURL��   � 1   E F��
�� 
ascr �  ��� � l  P P������  ��  ��   �  � � � =  T W � � � o   T U���� 0 dest   � m   U V � �  Send to Clipboard    �  � � � k   Z f � �  � � � O  Z d � � � I  ^ c�� ���
�� .JonspClpnull���     **** � o   ^ _���� 0 theurl theURL��   � 1   Z [��
�� 
ascr �  ��� � l  e e������  ��  ��   �  � � � C   i n � � � o   i j���� 0 dest   � m   j m � �  Paste to Colloquy:     �  � � � k   q � � �  � � � r   q | � � � n  q z � � � I   r z�� ����� 0 striplen   �  � � � o   r s���� 0 dest   �  ��� � m   s v���� ��  ��   �  f   q r � o      ���� 0 dest   �  � � � O   } � � � � k   � � � �  � � � r   � � � � � n   � � � � � 1   � ���
�� 
trgA � n   � � � � � 4   � ��� �
�� 
cobj � m   � �����  � l  � � ��� � 6  � � � � � 2  � ���
�� 
chvC � =  � � � � � 1   � ���
�� 
pnam � o   � ����� 0 dest  ��   � o      ���� 0 
thechannel 
theChannel �  ��� � I  � ��� � �
�� .ccoRsCmXnull���     TEXT � l  � � ��� � b   � � � � � m   � � � �  pasted     � o   � ����� 0 theurl theURL��   � �� � �
�� 
sCm1 � o   � ����� 0 
thechannel 
theChannel � �� ���
�� 
sCm3 � m   � ���
�� savoyes ��  ��   � m   } � � ��null     ߀��  *Colloquy.app�   ��^�@�c`����    }�P   )       �L(�]�����  ~coRC   alis    H  Ladybird                   ���BH+    *Colloquy.app                                                    w���|�J        ����  	                Applications    ���"      �|�:      *  "Ladybird:Applications:Colloquy.app    C o l l o q u y . a p p    L a d y b i r d  Applications/Colloquy.app   / ��   �  ��� � l  � �������  ��  ��   �  � � � C   � � � � � o   � ����� 0 dest   � m   � � � �  Paste to Adium:     �  � � � k   � � � �  � � � O  � � � � � O  � � � � � I  � ����� �
�� .AdIMsndMnull���    cobj��   � �� ���
�� 
TO   � o   � ����� 0 theurl theURL��   � n   � � � � � 4   � ��� �
�� 
cobj � m   � �����  � l  � � �� � 6  � � � � � 2  � ��~
�~ 
Acht � =  � � � � � 1   � ��}
�} 
AchN � n  � � � � � I   � ��| ��{�| 0 striplen   �  � � � o   � ��z�z 0 dest   �  ��y � m   � ��x�x �y  �{   �  f   � ��   � m   � � � ��null     ߀��  *	Adium.app��ΰ   �^� �c`����    }�P   )       �L(�]�����  ~AdIM   alis    <  Ladybird                   ���BH+    *	Adium.app                                                       F���`��        ����  	                Applications    ���"      �`m�      *  Ladybird:Applications:Adium.app    	 A d i u m . a p p    L a d y b i r d  Applications/Adium.app  / ��   �  ��w � l  � ��v�u�v  �u  �w   �  � � � C   � � � � � o   � ��t�t 0 dest   � m   � � � �  Paste to iChat:     �  ��s � k    � �  � � � O   � � � I �r � �
�r .ichtsendnull���    obj  � o  �q�q 0 theurl theURL � �p �o
�p 
TO    l 
�n 4  
�m
�m 
pres l �l n  I  �k�j�k 0 striplen    o  �i�i 0 dest   	�h	 m  �g�g �h  �j    f  �l  �n  �o   � m   

�null     ߀��  *	iChat.app��ΰ   �^�@�c`����    }�P   )       �L(�]�����  ~fez!   alis    <  Ladybird                   ���BH+    *	iChat.app                                                       A�d<        ����  	                Applications    ���"      �d,      *  Ladybird:Applications:iChat.app    	 i C h a t . a p p    L a d y b i r d  Applications/iChat.app  / ��   � �f l �e�d�e  �d  �f  �s  ��  ��  �� 0 dest   j o    �c�c "0 thedestinations theDestinations��   I  l     �b�a�b  �a    l     �`�`   O I strip the first `num` characters from `longstring`, returning the result     i     I      �_�^�_ 0 striplen    o      �]�] 0 
longstring   �\ o      �[�[ 0 num  �\  �^   L      c      l    �Z n      7  �Y 
�Y 
cha  l   	!�X! [    	"#" o    �W�W 0 num  # m    �V�V �X     ;   
  o     �U�U 0 
longstring  �Z   m    �T
�T 
TEXT $%$ l     �S�R�S  �R  % &'& l     �Q(�Q  ( O I split `aString` into several items of a list, using `sep` as a separator   ' )�P) i   *+* I      �O,-�O 	0 split  , o      �N�N 0 astring aString- �M.�L
�M 
by  . o      �K�K 0 sep  �L  + k     // 010 q      22 �J3�J 0 alist aList3 �I�H�I 
0 delims  �H  1 454 r     676 n    898 1    �G
�G 
txdl9 1     �F
�F 
ascr7 o      �E�E 
0 delims  5 :;: r    <=< o    �D�D 0 sep  = n     >?> 1    
�C
�C 
txdl? 1    �B
�B 
ascr; @A@ r    BCB n    DED 2   �A
�A 
citmE o    �@�@ 0 astring aStringC o      �?�? 0 alist aListA FGF r    HIH o    �>�> 
0 delims  I n     JKJ 1    �=
�= 
txdlK 1    �<
�< 
ascrG L�;L L    MM o    �:�: 0 alist aList�;  �P       �9NOPQR�9  N �8�7�6�5
�8 .aevtoappnull  �   � ****�7 .0 sendurltodestinations sendURLToDestinations�6 0 striplen  �5 	0 split  O �4 ,�3�2ST�1
�4 .aevtoappnull  �   � ****�3 0 argv  �2  S �0�0 0 argv  T �/�.�-�,
�/ 
cobj�. 0 argurl argURL�- "0 argdestinations argDestinations�, .0 sendurltodestinations sendURLToDestinations�1 ��k/E�O��l/E�O*��l+ P �+ K�*�)UV�(�+ .0 sendurltodestinations sendURLToDestinations�* �'W�' W  �&�%�& 0 theurl theURL�% "0 thedestinations theDestinations�)  U �$�#�"�!� �$ 0 theurl theURL�# "0 thedestinations theDestinations�" 0 sep  �! 0 
thechannel 
theChannel�  0 dest  V ) Y������ x ��� ��� �� ��� ��X�� ������ � ��
�	��� �
��
� 
by  � 	0 split  
� 
kocl
� 
cobj
� .corecnte****       ****
� 
TEXT
� .miscactvnull��� ��� null
� 
sele
� 
ascr
� .GURLGURLnull��� ��� TEXT
� .JonspClpnull���     ****� � 0 striplen  
� 
chvCX  
� 
pnam
� 
trgA
� 
sCm1
� 
sCm3
� savoyes � 
� .ccoRsCmXnull���     TEXT
�
 
Acht
�	 
AchN� 
� 
TO  
� .AdIMsndMnull���    cobj
� 
pres
� .ichtsendnull���    obj �()�E�O��l E�O�[��l kh ��&E�O��  � *j 	O�*�,FUOPY ��  � �j UOPY Ѥ�  � �j UOPY ��a  K)�a l+ E�Oa  3*a -a [a ,\Z�81�k/a ,E�Oa �%a �a a a  UOPY k�a  8a  ,*a  -a [a !,\Z)�a "l+ 81�k/ *a #�l $UUOPY -�a % $a & �a #*a ')�a "l+ /l (UOPY h[OY��Q ���YZ� � 0 striplen  � ��[�� [  ������ 0 
longstring  �� 0 num  �  Y ������ 0 
longstring  �� 0 num  Z ����
�� 
cha 
�� 
TEXT�  �[�\[Z�k\62�&R ��+����\]���� 	0 split  �� 0 astring aString�� ������
�� 
by  �� 0 sep  ��  \ ���������� 0 astring aString�� 0 sep  �� 0 alist aList�� 
0 delims  ] ������
�� 
ascr
�� 
txdl
�� 
citm�� ��,E�O���,FO��-E�O���,FO�ascr  ��ޭ