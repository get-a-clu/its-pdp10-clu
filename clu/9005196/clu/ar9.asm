�r�A�   5   b�����                                       ���  P�   @ H�
  @                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 CNh  *    �� �1�n"c8h~ CNh  q2| � �-�n5�8h~ MVt= "L   �} �)�n0�8h~ Y&tP "\    `�n0
�8h~ a<P $    L@�n.�Y8h~ a  *L   � �8a"98h~ a4@"`   � ��n.�8h~ e0 "D   � ��n0	o8h~ gfnH1*T    `�n0 _8h~ i?90\   $`8`Z'8h~ ���YQ*L   �5 ��n0�k8h~ ����%CNh  �S ��n-�8iZ    'Q    .�   �  "�    �   �  �   �  
[   �t   f�     �  9      #9�  &��  '    �       �       	�       �       �       �       ��       �       �       �   !    �   #    �   %    �   '    �   )    �   +    �   -    �   /    �   1    �   3    �   5    �   7    �   9    �   ;    �   =    �   ?     �   A    !�   C    "�   E    #�   G    $�   I    %�   K    &�   M    '�   O    (�   Q    )�   S    *�   U    +�   W    ,�   Y    -�   [    .�   ]    /�   _    0�   a    1�   c    2�   e    3�   g    4�   i    5�   k    6�   m    7�   o    8�   q    9�   s    :�   u    ;�   w    <�   y    =�   {    >�   }    ?�       @�   �    A�   �    B�   �    C�   �    D�   �    E�   �    F�   �    G�   �    H�   �    I�   �    J�   �    K�   �    L�   �    M�   �    N�   �    O�   �    P�   �    Q�   �    R�   �    S�   �    T�   �    U�   �    V�   �    W�   �    X�   �    Y�   �    Z�   �    [�   �    \�   �    ]�   �    ^�   �    _�   �    `�   �    a�   �    b�   �    c�   �     !$   tyo=file$tyo()
tyi=file$tyi()
file$puts(tyo,"\nLoading the fabulous ASM\n")
xload("urgz;asm xload")
ac=array$new()
scan$line(tyi,tyo,ac,"Input file: ")
infile=string$ac2s(ac)
ac=array$new()
scan$line(tyi,tyo,ac,"Output file: ")
outfile=string$ac2s(ac)
ac=array$new()
scan$line(tyi,tyo,ac,"Error file: ")
errfile=string$ac2s(ac)
assemble(infile,outfile,errfile)
file$puts(tyo,"\nDone.\n")
quit_()
!$   6  %a value1 is an evaluated expresion, it contains a relocation counter
%and a val cell

value1 = cluster is
	check_reloc,	%reloc counter had better be either 0 or 1 after complete parse
	and,		%logical and
	gt,		%greater than
	lt,		%less than
	or,		%logical or
	xor,		%exclusive or
	add,		%binary addition
	sub,		%binary subtraction
	neg,		%unary subtraction
	mul,		%binary mult
	div,		%binary div
	create,		%creates a value1 from a string (either int or text)
	print,		%for debugging
	v2s_18,		%converts to a string (18 bits)
	v2s,		%converts to a string (36 bits)
	%s2v		%same as create
	fetch_reloc,	%fetches the roloc counter (and checks it)
	zero,		%creates the zero word
	overflow_halfword,	%used for catching overflow errors (for 18 frobs
				%such as the lc
	equal,
	create_text
	;


	% a value1 has two parts, v is a 36 bit string which should 
	%look like a pdp-10 word
	%r is the relocation counter.  0=not relocatable;1=relocatable;other values
	%are illegal (except temporarily within calculations)

	rep = record [v:word, r:int]

	%the string could be ascii text, decimal digits, or octal digits

	create_text = proc (s:string) returns (cvt)
		return (rep${v:word$s2ascii(s),r:0})
		end create_text

	create = proc (s:string, reloc:int) returns (cvt) 
			signals (bad_arg, digit_out_of_range)
		len:int:=string$size (s)

		%an empty string is neither digits nor text
		%this is an internal check which should never signal 
		%(if the assembler is working)

		if len=0 then signal bad_arg end
		if s[len]='.' then s:=string$substr (s,1,len-1) %decimal 
				return (rep${v:s2w(s,10),r:reloc})
			else return (rep${v:s2w(s,8),r:reloc})	%octal
			end;
		except when digit_out_of_range: signal digit_out_of_range end
		end create;

	%internal function
	%converts a string of digits to a word using a base (usually decimal or octal)

	s2w = proc (s:string,base:int) returns (word) signals (digit_out_of_range)
		wbase:word:=word$create (0,base)
		sum:word:=word$create (0,0)
		for c:char in string$chars (s) do
			cval:int:=char$c2i(c)-char$c2i('0')
			if cval>=base then signal digit_out_of_range end
			sum:=sum*wbase+word$create (0,cval)
			end
		return (sum)
		end s2w

	%checks that the relocation counter is either 0 or 1

	check_reloc = proc (v1:cvt) signals (bad_reloc)
		r1:int:=v1.r
		if r1=0 then return
			elseif r1=1 then return
			else signal bad_reloc
			end
		end check_reloc		

	%can't and,or,xor,mul, or div, relocatable values

	and = proc (v1:cvt, v2:cvt) returns (cvt) signals (bad_reloc)
		if v1.r=0 cand v2.r=0 then
			return (rep${v:word$and (v1.v,v2.v),r:0})
			end
		signal bad_reloc
		end and

	or = proc (v1:cvt, v2:cvt) returns (cvt) signals (bad_reloc)
		if v1.r=0 cand v2.r=0 then
			return (rep${v:word$or (v1.v,v2.v),r:0})
			end
		signal bad_reloc
		end or

	xor = proc (v1:cvt, v2:cvt) returns (cvt) signals (bad_reloc)
		if v1.r=0 cand v2.r=0 then
			return (rep${v:word$xor (v1.v,v2.v),r:0})
			end
		signal bad_reloc 
		end xor

	%subtract the relocation counters
  
	sub = proc (v1:cvt, v2:cvt) returns (cvt)
		return(rep${v:v1.v-v2.v, r:v1.r-v2.r})
		end sub

	%add the relocation counters

	add = proc (v1:cvt, v2:cvt) returns (cvt)
		return (rep${v:v1.v+v2.v,r:v1.r+v2.r})
		end add
	
	mul = proc (v1:cvt, v2:cvt) returns (cvt) signals (bad_reloc)
	      	if v1.r=0 cand v2.r=0 then return (rep${v:v1.v*v2.v,r:0}) end
		signal bad_reloc
		end mul

	
	div = proc (v1:cvt, v2:cvt) returns (cvt) signals (bad_reloc)
		if v1.r=0 cand v2.r=0 then return (rep${v:v1.v/v2.v,r:0}) 
			else sign6   )0   al bad_reloc
			end
		end div

	%prints a value in octal
	% <first 6 digits><space><last 6 digits><space><either "R" or " ">		

       print = proc (v1:cvt,f:file)
		s:string:=value1$v2s(up(v1))
		file$puts (f,string$substr(s,1,6))
		file$putc (f,' ')
		file$puts (f, string$rest(s,7))
		if v1.r = 1 then file$puts (f," R")
			else file$puts (f, "  ")
			end
		end print

	%unary minus
	%negate the relocation counter

	neg = proc (v1:cvt) returns (cvt)
		return (rep${v: word$create (0,0) - v1.v, r:-v1.r})
		end neg

	%convert a value to 6 octal digits

	v2s_18 = proc (v1:cvt) returns (string)
		w:word:=word$get_right(v1.v)
		s:string:=word$unparse(w)
		l:int:=string$size(s)
		if l=6 then return (s)
			elseif l>6 then return (string$substr(s,1,6))
			else return (string$concat (string$substr("000000",1,6-l),s))
			end
		end v2s_18

	%convert a values to 12 octal digits

	v2s = proc (v1:cvt) returns (string)
		s:string:=word$unparse(v1.v)
		l:int:=string$size(s)
		if l=12 then return (s)
			elseif l>12 then return (string$substr(s,1,12))
			else return (string$concat (string$substr("000000000000",
								  1,12-l),s))
			end
		end v2s

	%rep.r
	%checks relocation counter

     	fetch_reloc = proc (v1:cvt) returns (bool) signals (bad_reloc)
		r1:int:=v1.r
		if r1=0 then return (false)
			elseif r1=1 then return (true)
			else signal bad_reloc
			end
		end fetch_reloc		

	%create the non-relocatable zero element

	%often returned to continue from error conditions

	zero = proc () returns (cvt)
		return (down (value1$create ("0",0)))
		end zero

	%compares just the v slot, not the relocation counters

	gt = proc (v1:cvt,v2:cvt) returns (bool)
		i11:int i12:int i21:int i22:int
		i11,i12:=word$w2i(v1.v)
		i21,i22:=word$w2i(v2.v)
		if i11>i21 then return (true)
			elseif i11<i21 then return (false)
			elseif i12>i22 then return (true)
			else return (false)
			end	
		end gt

	%does not compare the relocation counters

	lt = proc (v1:cvt,v2:cvt) returns (bool)
		i11:int,i12:int:=word$w2i(v1.v)
		i21:int,i22:int:=word$w2i(v2.v)
		if i11<i21 then return (true)
			elseif i11>i21 then return (false)
			elseif i12<i22 then return (true)
			else return (false)
			end
		end lt

	%checks for values exceeding 18 bits

	overflow_halfword = proc (v1:cvt) returns (bool)
		w:word:=v1.v
		wl:word:=word$get_left(w)
		if word$zero (wl) then return (false)
			else return (true)
			end
		end overflow_halfword

	%both the v and r slots must be =

	equal = proc (v1:cvt,v2:cvt) returns (bool)
		return (v1.v=v2.v cand v1.r=v2.r)
		end equal

	end value1

	%around for histerical reasons  --- should be deleted

	s2oct = proc (s:string) returns (int)
		total:int:=0
		count:int:=0
		for ptr:int in int$from_to_by(string$size(s),1,-1) do
			total:=total+ int$power(8,count) * 
				int$parse (string$substr(s,ptr,1))
			count:=count+1
			end
		return (total)
		end s2oct
)0 D  %top level parsing functions for pass1 of assembly problem

%if there is <idn> '='  sign in a line it returns true and
%assumes that there is an expr to
%the right.  It evals the expr (parse_expr) and stufs the value
%into the symbol table

parse_equates = proc (s:string, low:int, high:int, st:symtab) returns (bool)
	for ptr:int in int$from_to_by (low,high,1) do
		if s[ptr]='\"' then return (false) end
		if s[ptr]='=' then
			idn:string
			p1:int
			idn,p1:=parse_idn (s,low,ptr-1)
			%an idn cannot be an opcode
			if opcode_name (idn) then 
				error_print (st, "illegal idn, assuming not an equates",s)
				return (false)
				end
			%There should be an idn before an equal sign
			if idn="" then 
				error_print (st, "no idn before =, assuming not an equates",s)
				return (false)
				end
			%There shouldn't be any text between the idn the the equal sign
			if ~blank_line (s,p1,ptr-1) then 
				error_print (st, "no = after idn, assuming not an equates",s)
				return (false)
				end
			p2:int
			v1:value1
			%evaluate the right hand side 
			v1,p2:=parse_expr (s,ptr+1,high,st)
			%and store it away
			symtab$add(st,idn,v1,false)
			return (true)
			end
		end
	%couldn't find an equal sign
	return (false)
	end parse_equates

%the returned valued is a bool (true = found a pseudo;false = no pseudo found)
%if it finds a .ascii, then update the lc 
%if it finds a .end, then tell parse_line to stop (dot_end)

parse_pseudo = proc (s:string, low:int,high:int, st:symtab) returns (bool) 
		signals (dot_end)
	%all pseudo instructions are idns
	idn:string,ptr:int:=parse_idn(s,low,high)
	%dispatch for each possible pseudo instruction
	if idn = ".ascii" then		
			lc:value1:= st["."]
			arg:string:=get_ascii (st,s,ptr,high)
			%inc the lc once for each 5 chars in the argument
			for count:int in int$from_to_by(1,(4+string$size(arg))/5,1) do
				symtab$inc_lc (st)
					except when lc_overflow(lc1:value1):
						error_print (st,"lc overflow",s)
						symtab$replace (st,".",lc1)
						symtab$inc_lc (st)
						end
				enD   'J   d
			return (true)
		elseif idn=".title" then return (true)
		elseif idn= ".end" then signal dot_end	%tell parse_line to stop
		end;
	return (false)
	end parse_pseudo

%flush the comments

parse_comments = proc (s:string,low:int,high:int) returns (int)
	return (findc(';',s,low,high)-1)
	end parse_comments
 
parse_line = proc (s:string,st:symtab) signals (dot_end)
	symtab$inc_linenum(st)
		except when linenum_overflow: 
			error_print (st,"line number overflow",s) end
	s:=clear_invalid_chars (st,s)
	low:int:=1
	high:int:=string$size(s)
	lc:value1:=st["."]
	high:=parse_comments(s,low,high)
	low:=parse_labels(s,low,high,lc,st)
	if  	blank_line(s,low,high) then return
		elseif parse_pseudo(s,low,high,st) then return
		elseif parse_equates(s,low,high,st) then return
		else  	lc:= symtab$inc_lc (st)
			except when lc_overflow (lc_temp:value1):
				lc := lc_temp 
				error_print (st, "lc overflow",s) end
		end
	except when dot_end: signal dot_end return end
	end parse_line	

blank_line = proc (s:string, low:int, high:int) returns (bool)
	for ptr:int in int$from_to_by(low,high,1) do
		if s[ptr]~=' ' cand s[ptr]~='\t' then return (false) end
		end
	return (true)
	end blank_line

pass1 = proc (st:symtab)
	inf:file:=symtab$fetch_infile (st) 
	lc:value1:=value1$create("0",1)
	symtab$store_linenum (st,0)
	symtab$add(st,".",lc,false)
	while true do
		s:string:=file$gets(inf,'\n')
			except when eof: 
				error_print (st,"no end statement","")
				symtab$delete_non_labels (st)
				return 
				end
		parse_line (s,st)
		except when dot_end: 	
					symtab$delete_non_labels(st)
					return
					end
		end
	end pass1

parse_labels = proc (s:string,low:int,high:int,lc:value1,st:symtab) returns (int)
	for ptr:int in int$from_to_by(low,high,1) do
		if s[ptr]=':' then 
			idn:string
			i:int
			idn,i:=parse_idn(s,low,ptr)
					%an idn cannot be an opcode
			if opcode_name (idn) then 
				error_print (st, "illegal idn, assuming not label",s)
				return (low)
				end
			
			if ~blank_line (s,i,ptr-1) then 
				error_print (st, "no : after idn, assuming not label",s)
				return (low)
				end
			if idn="" then 
					error_print (st,"bad label, assume no label",s)
					return (low)
				else symtab$add(st,idn,lc,true)
				end
			ptr:=parse_labels(s,ptr+1,high,lc,st)
			return (ptr)
			end
		end
	return (low)
	end parse_labels
��
[*  %symbol table

%might be better called "environment" since it holds all the global values 
%which might be needed.

symtab = cluster is
	create,		%creates an empty symbol table
	fetch,		%fetches the value of an idn
	replace,	%replaces the value of an idn (the idn must have had a value)
	add,		%inserts an idn and a value into the symbol table
	print,		%prints the symbol table
	fetch_linenum,	%fetches the line number
	store_linenum,	
	inc_linenum,
	inc_lc,		%increments the location counter (lc)
	labelp,		%is an idn a label (not seen yet on pass2)? 
	fetch_title,
	store_title,
	delete_non_labels,	%clears out all idn values (except on labels) 
				%so pass2 won't get phase errors
	fetch_errf,
	fetch_infile,
	fetch_outfile,
	assign_files	%assigns the infile,outfile, and errfile
	;

	bucket = record [	key:string,		%an idn 
				datum:value1, 		%the value of the idn
				label:bool, 		%is the idn a label?
				valid:bool,		%is it currently valid
							%a non-label must be defined
							%on each pass before it 
							%is used on that pass
				seen_on_pass2:bool]	%has it been seen on pass2

	%the idns are stored in a hash table (htab) 
	%each entry is a bucket 
	%buckets is an array which holds the entries which share a common hash value
	
	buckets = array [bucket]	

	htab = array [buckets]

	%for sorting the hash table it is convient to use
	%the heap cluster.  A sorted_tab holds the idns in a heap.

	sorted_tab = heap [bucket]

	htab_length = 97	%arbitrary length (but should be prime)

	rep = record [	ln:int,		%line number 
			title:string, 
			infile:file, 	%source file
			outfile:file, 
			errfile:file,
			tab:htab]

	create = proc () returns (cvt)
		return (rep${	ln:1,
				title:"",
				infile:file$tyi(),
				outfile:file$tyo(),
				errfile:file$tyo(),
				tab:create_htab(htab_length)})
		end create

	create_htab = proc (len:int) returns (htab)
		ht:htab:=htab$create(0)
		for i:int in int$from_to_by (1,len,1) do
			htab$addh (ht,buckets$create(0))
			end
		return (ht)
		end create_htab

	fetch = proc (st:cvt, k:string) returns (value1)
		buck:bucket := lookup (st,k)
			except 
			when illegal_key:
				error_print (up(st),"illegal idn",k)
				return (value1$zero())
			when key_not_found:
				error_print (up(st),"undefined symbol",k)
				zero:value1:=value1$zero()
				hval:int:=hashit(k)
				buckets$addh (st.tab[hval], bucket${	key:k,
						  		datum:zero,
								label:false,
								valid:true,
								seen_on_pass2:false})
				return (zero)
				end
		if ~buck.valid then 
			error_print (up(st),"invalid datum",k)
			return (value1$zero*   /   ())
			end
		return (buck.datum) 
		end fetch

	replace = proc (st:cvt, k:string, newval:value1)
		buck:bucket:=lookup(st,k)
			%key_not_found indicates a real program error
		if buck.label then 
			error_print (up(st),"illegal redefinition",k)
			return
			end 
		buck.datum:=newval
		buck.valid:=true
		return
		end replace

	add = proc (st:cvt, k:string, val:value1, lab:bool)
		buck:bucket:=lookup(st,k)
			except when key_not_found:
				hval:int:=hashit(k)
				buckets$addh (st.tab[hval], bucket${
				     			key:k,
				     			datum:val,
				     			label:lab,
				     			valid:true,
							seen_on_pass2:false})
			        return
				end
		if lab then	error_print (up(st), "label already defined",k)
				return
				end
		if buck.label then
			error_print (up(st),"illegal redefinition",k)
			return
			end
		buck.datum := val
		buck.valid := true
		return
		end add

	%an internal procedure -- if (when) tab becames a hash table it would
	%	most untasteful to let the user sort tab
	
	sort = proc (idn_tab:htab) returns (sorted_tab)
		stab:sorted_tab:=sorted_tab$create(lt)
		for i:buckets in htab$elements (idn_tab) do
			for j:bucket in buckets$elements (i) do
				sorted_tab$insert (stab,j)
				end
			end
		return (stab)
        	end sort;

	print = proc (st:cvt)
		stab:sorted_tab:=sort (st.tab)
		f:file:=st.outfile
		while true do
			buck:bucket:=sorted_tab$remove(stab)
			except when empty: return end
			if buck.key~="." then
				file$puts (f,buck.key)
				file$putc (f,'\t')
				value1$print(buck.datum, f)
				file$putc (f,'\n')
				end
			end
		end print

	hashit = proc (s:string) returns (int) signals (empty_idn)
		sze:int:=string$size (s)
		if sze=0 then signal empty_idn end
		i1:int i2:int
		if sze>=1 then i1:=char$c2i(s[1])
			else i1:=1
			end
		if sze>=2 then i2:=char$c2i(s[2]) 
			else i2:=1
			end
		val:int:=int$mod(i1*i2,htab_length)
		return (val)
		%didn't work to catch bounds error -- 
		%except when bounds: return (val) end
		end hashit

	lt = proc (b1:bucket, b2:bucket) returns (bool)
		return (string$lt (b1.key,b2.key))
		end lt

	string_lower = proc (s:string) returns (string)
		if s="" then return (s)
			else  return (string$concat (string$c2s(char$lower (s[1])), 
						     string_lower (rest (s))))
			end
		end string_lower

	delete_non_labels = proc (st:cvt)
		for bucks:buckets in htab$elements(st.tab) do
			for buck:bucket in buckets$elements(bucks) do
				if ~buck.label then 
					buck.valid:=false
					end
				end
			end
			return
		end delete_non_labels

	fetch_title = proc (st:cvt) returns (string)
		return (st.title)
		end fetch_title

	store_title = proc (st:cvt, s:string)
		st.title:=s
		return
		end store_title

	fetch_linenum = proc (st:cvt) returns (int)
		return (st.ln)
		end fetch_linenum

	inc_linenum = proc (st:cvt) signals (linenum_overflow)
		st.ln:=st.ln+1
		if st.ln>9999 then signal linenum_overflow end
		end inc_linenum

	inc_lc = proc (st:symtab) returns (value1) signals (lc_overflow (value1))
		lc:value1:=st["."]
		if value1$overflow_halfword(lc) then 
			signal lc_overflow (value1$create ("0",1))
			end
		lc:=lc+value1$create("1",0)
		symtab$replace (st,".",lc)
		return (lc)
		end inc_lc

	store_linenum = proc (st:cvt,newln:int)
		st.ln:=newln
		end store_linenum

	labelp = proc (st:cvt, s:string) returns (bool) signals (key_not_found)
		buck:bucket:=lookup(st,s)
			except when key_not_found: signal key_not_found end
		result:bool:=buck.label cand ~buck.seen_on_pass2
		buck.seen_on_pass2:=true
		return (result)
		end labelp

	lookup = proc (st:rep, s:string) returns (bucket) 
			signals (illegal_key, key_not_found)
		if opcode_name(s) then signal illegal_key end
		hval:int:=hashit(s)
		for buck:bucket in buckets$elements (st.tab[hval]) do
			if buck.key=s then return (buck) end
			end
		signal key_not_found
		end lookup

	assign_files = proc (st:cvt, inf:file, outf:file, errf:file)
		st.infile:=inf
		st.outfile:=outf
		st.errfile:=errf
		return
		end assign_files

	fetch_errf = proc (st:cvt) returns (file)
		return (st.errfile)
		end fetch_errf

	fetch_infile = proc (st:cvt) returns (file)
		return (st.infile)
		end fetch_infile

	fetch_outfile = proc (st:cvt) returns (file)
		return (st.outfile)
		end fetch_outfile

	fetch_errfile = proc (st:cvt) returns (file)
		return (st.errfile)
		end fetch_errfile


	end symtab


	error_print = proc (st:symtab, problem:string, text:string)
		f:file:=symtab$fetch_errf (st)
		file$puts(f, "\nERROR\t")
		file$puti(f,symtab$fetch_linenum(st))
		file$puts (f,"\n\tSOURCE\t")
		file$puts(f,text)
		file$puts (f,"\n\tPROBLEM\t")
		file$puts(f,problem)
		file$putc(f,'\n')
		return
		end error_print
	/ �t b  data_rep = proc(v:value1) returns (string)
	r:string:=value1$v2s(v)
	r:=string$substr(r,1,6)||" "||string$rest(r,7)
	if value1$fetch_reloc(v) then r:=r||" R" end
	return(r)
end data_rep

lc_rep = proc(st:symtab) returns(string)
	if value1$ove b   )x   rflow_halfword(st["."]) then
		error_print(st,"intended address too large,reset to 0",
				value1$v2s(st["."]))
		symtab$replace(st,".",value1$create("0",1)) end
	r:string:=value1$v2s_18(st["."])
	if value1$fetch_reloc(st["."]) then r:=r||" R" end
	return(r)
end lc_rep

opcode_rep = proc(n:string,acc,inx,addr:value1,ind:string) returns(string)
	signals (bad_indirect)

	if ind~="0" cand ind~="1" then signal bad_indirect end

	a:string:=string$rest(value1$v2s(acc),11)
	a:=string$rest(o2b(a),3)

	i:string:=string$rest(value1$v2s(inx),11)
	i:=string$rest(o2b(i),3)

	v:string:=opcode_code(n)||b2o(a||ind||i)||" "||value1$v2s_18(addr)
	if value1$fetch_reloc(addr) then v:=v||" R" end
	return(v)
end opcode_rep

o2b = proc(o:string) returns(string)
	signals (not_octal)
	%returns a string of size 3*size(o)-leading zeros are not removed

	if o="" then signal  not_octal end

	b:string:=""
	for c:char in string$chars(o) do
		if     c='0' then b:=b||"000"
		elseif c='1' then b:=b||"001"
		elseif c='2' then b:=b||"010"
		elseif c='3' then b:=b||"011"
		elseif c='4' then b:=b||"100"
		elseif c='5' then b:=b||"101"
		elseif c='6' then b:=b||"110"
		elseif c='7' then b:=b||"111"
		else signal not_octal end
		end
	return(b)
end o2b

opcode_code = proc(s:string) returns(string)
	signals (not_opcode)

	if s = "add" then return("270")
	elseif s = "sub" then return("274")
	elseif s = "move" then return("200")
	elseif s = "jrst" then return("254")
	elseif s = "jsp" then return("265")
	elseif s = "came" then return("312")
	elseif s = "camg" then return("317")
	elseif s = "caml" then return("311")
	elseif s = "camn" then return("316")
	elseif s = "xct" then return("256")
	else signal not_opcode end
end opcode_code

ascii_rep = proc(s:string) returns(as)
	as=array[string]
	n:int:=string$size(s)//5
	if n>0 then s:=s||string$rest("\000\000\000\000",n) end
	r:as:=as$new()
	b:string:=""
	for c:char in string$chars(s) do
		t:string:=convert(char$c2i(c),2)
		b:=b||string$rest("000000",string$size(t))||t 
		if string$size(b)=35 then
			o:string:=b2o(b||"0")
			as$addh (r,string$substr(o,1,6)||" "||string$rest(o,7))
			b:="" end
		end
	return(r)
end ascii_rep

convert = proc(d:int,base:int) returns(string)
	signals (negative_arg, bad_base)

	if d<0 then signal negative_arg end
	if base<=1 cor base>10 then signal bad_base end

	if d=0 then return("0") end

	c:string:=""
	while d>0 do
		r:int:=d//base
		c:=int$unparse(r)||c
		d:=(d-r)/base
		end
	return(c)
end convert

b2o = proc(b:string) returns(string)
	signals (not_binary)

	if b="" then signal not_binary end

	r:int:=string$size(b)//3
	if r=1 then b:="00"||b end
	if r=2 then b:="0"||b end

	o:string:=""
	for i:int in int$from_to_by(1,string$size(b),3) do
		s:string:=string$substr(b,i,3)
		if     s="000" then o:=o||"0"
		elseif s="001" then o:=o||"1"
		elseif s="010" then o:=o||"2"
		elseif s="011" then o:=o||"3"
		elseif s="100" then o:=o||"4"
		elseif s="101" then o:=o||"5"
		elseif s="110" then o:=o||"6"
		elseif s="111" then o:=o||"7"
		else signal not_binary end
		end
	return(o)
end b2o)x f|  pass2 = proc(st:symtab)
	p:page:=page$create(st) %the output page
	symtab$add(st,".",value1$create("0",1),false) %initialize lc
	symtab$store_linenum(st,1)

	l:line:=line$next(st,symtab$fetch_infile(st))
	while true do
		% l is the line to be processed
		for lab:string in line$labels(l) do check_label(st,lab) end

		ln:string:=int$unparse(symtab$fetch_linenum(st))

		if line$is_noop(l) then
			page$put(p,ln,"","",line$input(l))
		elseif line$is_title(l) then
			symtab$store_title(st,line$text(l))
			page$start(p)
			page$put(p,ln,"","",line$input(l))
		elseif line$is_equate(l) then
			page$put(p,ln,"",data_rep(line$exp(l)),line$input(l))
			symtab$add(st,line$idn(l),line$exp(l),false)
		elseif line$is_opcode(l) then
			d:string:=opcode_rep(line$idn(l),line$accum(l),line$index(l),
					      line$address(l),line$indirect(l))
			page$put(p,ln,lc_rep(st),d,line$input(l))
			symtab$inc_lc(st) except when lc_overflow: end
		elseif line$is_data(l) then
			page$put(p,ln,lc_rep(st),data_rep(line$exp(l)),line$input(l))
			symtab$inc_lc(st) except when lc_overflow: end
		elseif line$is_ascii(l) then
			s:array[string]:=ascii_rep(line$text(l))
			page$put(p,ln,lc_rep(st),s[1],line$input(l))
			symtab$inc_lc(st) except when lc_overflow: end
			for n:int in int$from_to_by(2,array[string]$high(s),1) do
				page$put(p,"",lc_rep(st),s[n],"")
				symtab$inc_lc(st) except when lc_overflow: end
				end
		elseif line$is_end(l) then
			page$put(p,"",string$rest(data_rep(line$exp(l)),8),"",
				line$input(l))
			flush_remaining_lines(st,symtab$fetch_infile(st),p)
			BREAK
		elseif line$is_noline(l) then
			error_print(st,".end missing,.end 0 assumed","")
			%stuff real assem. would do to "assume" .end 0
			BREAK
		else 
			error_print(st,"ASSEMBLER ERROR-non existant line","")
			return end
		symtab$inc_linenum(st)
			except when linenum_overflow:
			err|    B   or_print(st,"line number too large,reset to 1","")
			symtab$store_linenum(st,1) end
		l:=line$next(st,symtab$fetch_infile(st))
		end
	print_symtab(st)
end pass2
��2  %file of parsing functions

%assume that equates may NOT have forward references

%parses and idn and returns it
%if there isn't one, it returns the empty string and a pointer
%to the first non-blank char

parse_idn = proc (s:string,low:int, high:int) returns (string, int)
	ptr:int:=low
	%remove blanks
	while ptr<= high cand (s[ptr]=' ' cor s[ptr]='\t') do ptr:=ptr+1 end
	%the first char of an idn must be alpabetic (or . or _)
	if ptr>high cor ~alpha(s[ptr]) then return ("",ptr) end 
	low:=ptr
	%the others must be alphanumeric or . or _
	while ptr<=high cand alphanum (s[ptr]) do
		ptr:=ptr+1
		end
	return (string$substr(s, low, ptr-low),ptr)
	end parse_idn

%is c alphanumeric or . or _?

alphanum = proc (c:char) returns (bool)
	if c>= 'a' cand c<='z' then return (true) end
	if c>= 'A' cand c<='Z' then return (true) end
	if c>='0' cand c<='9' then return (true) end
	if c='.' then return (true) end
	if c='_' then return (true) end
	return (false)
	end alphanum

%is c alphabetic or . or _?

alpha = proc (c:char) returns (bool)
	if c>='a' cand c<='z' then return (true)
		elseif c>='A' cand c<='Z' then return (true)
		elseif c='.' cor c='_' then return (true)
		else return (false)
		end
	end alpha

%is c numeric?

num = proc (c:char) returns (bool)
	if c>= '0' cand c<='9' then return (true)
		else return (false)
		end
	end num

%parses a literal (either text in quotes or digits (followed by possibly .))

parse_literal = proc (s:string,low:int,high:int,st:symtab) returns (value1,int) 
			signals (bad_string)
	ptr:int:=low
	while s[ptr]=' ' cor s[ptr]='\t' do ptr:=ptr+1 end
	%assuming that the literal is text, look for the high bound
	low:=ptr
	if s[ptr]='\"'then 
		ptr:=ptr+1
		while ptr<=high cand s[ptr]~='\"' do
			if s[ptr]='\\' then 
					if ptr=high then 
						signal bad_string 
						end
					ptr:=ptr+1 
					end
			ptr:=ptr+1 
			end
		end
	hb:int
	if ptr=high then hb:=ptr else hb:=ptr+1 end
	if ptr~=low then 
		return (value1$create_text (get_ascii(st,s,low,ptr)),hb) 
		end 
	%since there wasn't a string, there must be a number
	%parse out digits
	while ptr<= high cand num (s[ptr]) do
		ptr:=ptr+1
		end
	if ptr<=high cand s[ptr]='.' then ptr:=ptr+1 end
	if blank_line (s, low, ptr) then signal bad_string end
	%if I still can't find a literal there must be an error in the input file
	if ptr=low then
		error_print (st,"missing literal, 0 assumed",s)
		return (value1$zero(),high)
		end
	new:string:=string$substr(s, low, ptr-low)
	return(value1$create(new,0),ptr)
		except when digit_out_of_range: 
			error_print (st,"digit exceeds base",new)
			return (value1$zero(),ptr)
			end
	end parse_literal

%assume that there can be no newlines within expr (even within parens)
parse_expr = proc (s:string,low:int,high:int,st:symtab) returns (value1,int)
	%pass the buck
	v:value1,i:int:=parse_expr1(s,low,high,st)
	%the relocation counter should be either 0 or 1
	value1$check_reloc(v)
	except when bad_reloc:	error_print(st,"bad relocation count",s)
				return (value1$zero(),i)
	 			end
	%the whole line should be consumed
	if ~blank_line (s,i+1,high) then error_print (st, "bad expr",s) 
					return (value1$zero(),high)
					end
	return (v,i)
	end parse_expr

%parse a term (either a literal or an idn)
parse_term = proc (s:string,low:int,high:int,st:symtab) returns (value1,int)
	ptr:int:=low
	%remove blanks
	while low<=high cand (s[ptr]=' ' cor s[ptr]='\t') do ptr:=ptr+1 end
	%hopefully there is term to be found
	if ptr > high then error_print (st,"unexpected end of line",s) 
		return (value1$zero(),high) end
	low:=ptr
	v1:value1
	%oh yes, a term could also be a unary minus of a term
	if s[ptr] = '-' then
		v1,ptr:=parse_term(s,ptr+1,high,st)
		return (value1$neg(v1),ptr)
		end
	
	%check for mismatched parens
	%and parse the contents of parens (recursively)
	if s[ptr] = '<' then
		v1,ptr:=parse_expr(s,ptr+1,high-1,st)
		ptr:=ptr+1
		while ptr<=high cand (s[ptr]=' ' cor s[ptr]='\t') do ptr:=ptr+1 end
		if ptr>high cor s[ptr]~='>' then 
				error_print (st,"mismatched parens",s)
				return (value1$zero(),high) 
				end
		return (v1,ptr) 
		end
	
	if s[ptr]='>' then 
		error_print (st,"too many right parens",s)
		return (value1$zero(),high)
		end
	%let idn be the result
	%first try to get an idn
	%and if that fails then try to get a literal
	
	idn:string
	idn,ptr := parse_idn (s,ptr,high)
	if idn="" then v1,ptr:=parse_literal(s,low,high,st)
		else v1:= st[idn]
		end 
	except when bad_string:	error_print (st, "bad string",s)
				return (value1$zero(),high)
				end
	return (v1,ptr)
	end parse_term

%the guts of expr parsing

parse_expr1 = proc (s:string,low:int,high:int,st:symtab) returns (value1,int)
	idn:string
	ptr:int
	v1:value1
	v1,ptr:=parse_term(s,low,high,st)
	%let v1 be an accumulator
	%2   $l   put the first term in the ac
	%if there is an operation then apply the operator to the first term
	%and the next term -- right to left order of operations
	%continue until the end of line (or something goes wrong)
	v2:value1
	while true do
		if ptr>=high then return(v1,high) end	
		%dispatch to the right operator
		c:char:= s[ptr]
		if c= '+' then v2,ptr := parse_term (s,ptr+1,high,st)
				v1:=value1$add (v1, v2)
			elseif c= '-' then v2,ptr:=parse_term(s,ptr+1,high,st)
				v1:=value1$sub (v1,v2)
			elseif c='*' then v2,ptr:=parse_term(s,ptr+1,high,st)
				v1:=value1$mul (v1,v2)
			elseif c='/' then v2,ptr:=parse_term(s,ptr+1,high,st)
				v1:=value1$div (v1,v2)
			elseif c='&' then v2,ptr:=parse_term(s,ptr+1,high,st)	
				v1:=value1$and (v1,v2)
			elseif c='|' then v2,ptr:=parse_term(s,ptr+1,high,st)
				v1:=value1$or (v1,v2)
			elseif c='#' then v2,ptr:=parse_term (s,ptr+1,high,st)
				v1:=value1$xor (v1,v2)
			elseif c= ' ' cor c= '\t' then ptr:=ptr+1
			elseif c='>' then return (v1,ptr-1)
			else error_print (st,"bad expr",s) 
				return (value1$zero(),high)
			end
		end
	except when bad_reloc: 
		error_print (st, "bad relocation counter", s)
		return (value1$zero(),high)
		end
	return (v1,ptr)
	end parse_expr1

%for debuging only -- please ignor

test_parse_expr = proc (s:string)
	v1:value1
	st:symtab:=symtab$create()
	ptr:int
	v1,ptr := parse_expr(s,1,string$size(s),st)
	int$print (ptr,file$tyo())
	char$print ('\n',file$tyo())
	value1$print(v1,file$tyo())
	end test_parse_expr
$l #$   page = cluster is create,put,start
	%the output page layout
rep=record[st:symtab,maxl,lineno,pageno:int]

create = proc(st1:symtab) returns(cvt)
	return(rep${st:st1,maxl:55,lineno:0,pageno:0})
end create

start = proc(p:cvt)
	f:file:=symtab$fetch_outfile(p.st)
	if p.pageno>0 then file$putc(f,'\p') end
	p.pageno:=p.pageno+1
	p.lineno:=0
	file$putc(f,'\n')
	file$puts(f,"Page ")
	file$puti(f,p.pageno)
	file$puts(f,"     ")
	file$puts(f,symtab$fetch_title(p.st))
	file$puts(f,"\n\nline  addr   R data          R   text\n")
end start


put = proc(p:cvt,l,a,d,t:string)
	f:file:=symtab$fetch_outfile(p.st)
	if p.pageno=0 cor p.lineno=p.maxl then start(up(p)) end
	file$putc(f,'\n')
	p.lineno:=p.lineno + 1
	file$puts(f,string$rest("    ",string$size(l)+1))
	file$puts(f,l)
	file$puts(f,"  ")
	file$puts(f,a)
	file$puts(f,string$rest("        ",string$size(a)+1))
	file$putc(f,' ')
	file$puts(f,d)
	file$puts(f,string$rest("               ",string$size(d)+1))
	file$puts(f,"   ")
	file$puts(f,t)
end put

end page
#$   ^   line = cluster is
	next,			% ->line,  get & parse new line
	is_noline,		% null line
	is_noop,		% line with no <instruction>
	is_opcode,		% machine instruction
	is_data,		% data word
	is_equate,		% an equate
	is_ascii,		% .ascii pseudo op
	is_title,		% .title pseudo op
	is_end,			% .end pseudo op
	labels,			% all labels attached to the line
	idn,			% the identifier in the line if any
	exp,			% the expression in the line if any
	accum,			% the accumulator part of opcode
	index,			% the index reg part of opcode
	address,		% the address part of opcode
	indirect,		% the indirect bit in opcode
	text,			% the argument to .ascii or .title
	input			% a copy of the input line

as=array[string]
opval=record[accum,index,address:value1,indir:string]
argval=oneof[no:null,	  %for noline,noop
	     exp:value1,  %for equate,data,end
	     op:opval,	  %for opcode
	     text:string  %for ascii,title
	    ]
rep=record[labels:as, idn:string, arg:argval, input:string, typ:string]

next = proc(st:symtab,f:file) returns(cvt)
	l:rep:=rep${labels:as$new(),
		    idn:"",
		    arg:argval$make_no(nil),
		    input:"",
		    typ:"noline"}
	l.input:=file$gets(f,'\n') except when eof: return(l) end
	s:string:=clear_invalid_chars(st,l.input)
	lbd:int:=1
	hbd:int:=findc(';',s,1,string$size(s)) - 1  %strip off the comment

	while true do	% this loop is executed once for each label
		%lbd points to the first unexamined char
		%hbd points to last char to be considered
 		id:string,ptr:int:=parse_idn(s,lbd,hbd)
		l.idn:=id

		if id="" then 	%no idn found
			if ptr>hbd then
				l.typ:="noop"
			 else
				l.typ:="data"
				l.arg:=argval$make_exp(eval_expr(st,s,ptr,hbd)) end
			return(l) end
		if id=".title" then
			l.typ:="title"
			l.arg:=argval$make_text(get_title(s,ptr,hbd))
			return(l) end
		if id=".ascii" then
			l.typ:="ascii"
			l.arg:=argval$make_text(get_ascii(st,s,ptr,hbd))
			return(l) end
		if id=".end" then
			l.typ:="end"
			l.arg:=argval$make_exp(get_end(st,s,ptr,hbd))
			return(l) end
		if opcode_name(id) then
			l.typ:="opcode"
			l.arg:=argval$make_op(get_op(st,s,ptr,hbd))
			return(l) end

		%check what char follows id
		while ptr<=hbd cand (s[ptr]=' ' cor s[ptr]='\t') do ptr:=ptr+1 end
		if ptr>hbd cor (s[ptr]~= '=' cand s[ptr]~=':') then
			l.typ:="data"
			l.arg:=argval$make_exp(eval_expr(st,s,lbd,hbd))
			l.idn:=""
			return(l) end
		if s[ptr] = '=' then
			l.typ:="equate"
^   -^   			l.arg:=argval$make_exp(eval_expr(st,s,ptr+1,hbd))
			return(l) end
		as$addh(l.labels,id)
		lbd:=ptr+1
		end
end next

is_noline = proc(l:cvt) returns (bool)
	return(l.typ="noline")
end is_noline

is_noop = proc(l:cvt) returns (bool)
	return(l.typ="noop")
end is_noop

is_opcode = proc(l:cvt) returns (bool)
	return(l.typ="opcode")
end is_opcode

is_equate = proc(l:cvt) returns (bool)
	return(l.typ="equate")
end is_equate

is_data = proc(l:cvt) returns (bool)
	return(l.typ="data")
end is_data

is_ascii = proc(l:cvt) returns (bool)
	return(l.typ="ascii")
end is_ascii

is_title = proc(l:cvt) returns (bool)
	return(l.typ="title")
end is_title

is_end = proc(l:cvt) returns (bool)
	return(l.typ="end")
end is_end

labels = iter(l:cvt) yields(string)
	for s:string in as$elements(l.labels) do yield(s) end
end labels

idn = proc(l:cvt) returns(string)
	return(l.idn)
end idn

exp = proc(l:cvt) returns(value1)
	signals (bad_type)

	if l.typ="equate" cor l.typ="data" cor l.typ="end"
		then return (argval$value_exp(l.arg))
		else signal bad_type end
end exp

accum = proc(l:cvt) returns (value1)
	signals (not_opcode)

	if l.typ = "opcode" then return(argval$value_op(l.arg).accum)
		else signal not_opcode end
end accum

index = proc(l:cvt) returns (value1)
	signals (not_opcode)

	if l.typ = "opcode" then return(argval$value_op(l.arg).index)
		else signal not_opcode end
end index

address = proc(l:cvt) returns (value1)
	signals (not_opcode)

	if l.typ = "opcode" then return(argval$value_op(l.arg).address)
		else signal not_opcode end
end address

indirect = proc(l:cvt) returns (string)
	signals (not_opcode)

	if l.typ = "opcode" then return(argval$value_op(l.arg).indir)
		else signal not_opcode end
end indirect


text = proc(l:cvt) returns(string)
	signals (bad_type)

	if l.typ = "ascii" cor l.typ = "title"
		then return(argval$value_text(l.arg))
		else signal bad_type end
end text


input = proc(l:cvt) returns(string)
	return(l.input)
end input


%internal procedures
get_title = proc(s:string, l,h:int) returns (string)
	%eliminate surrounding blanks
	while l<=h cand (s[l]=' ' cor s[l]='\t') do l:=l+1 end
	while h>=l cand (s[l]=' ' cor s[l]='\t') do h:=h-1 end
	return(string$substr(s,l,h-l+1))
end get_title

get_end = proc(st:symtab,s:string,l,h:int) returns (value1)
	%end argument is an address - check for halfword overflow
	v:value1:=eval_expr(st,s,l,h)
	if value1$overflow_halfword(v) then
		error_print(st,"address too large,truncated",string$substr(s,l,h-l+1))
		end
	return(v)
end get_end

get_op = proc(st:symtab, s:string, l,h:int) returns(opval)
	%set default values
	v:opval:=opval${accum,index,address:value1$zero(),indir:"0"}
	
	p:int:=findc(',',s,l,h)
	if p<=h then %that means findc found ',' so have an accum field
		v.accum:=get_reg(st,string$substr(s,l,p-l))
		l:=p+1 end

	%find next non blank char
	while l<=h cand (s[l]=' ' cor s[l]='\t') do l:=l+1 end
	if l<=h cand s[l]='@' then %have an indirect field
		v.indir:="1"
		l:=l+1 end

	%set l to first non blank char, p to next '('
	while l<=h cand (s[l]=' ' cor s[l]='\t') do l:=l+1 end
	p:=findc('(',s,l,h)
	if l<=h cand s[l]~='(' then %have an address field
		v.address:=eval_expr(st,s,l,p-1)
		if value1$overflow_halfword(v.address) then
			error_print(st,"address too large truncated",
						string$substr(s,l,p-l)) end
		l:=p end

	if l<=h cand s[l]='(' then %have an index field
		p:=findc(')',s,l,h)
		if p>h then error_print(st,"missing ) assumed present",
					string$substr(s,l,h-l+1)) end
		v.index:=get_reg(st,string$substr(s,l+1,p-l-1))
		end
	return(v)
end get_op


get_reg = proc(st:symtab,s:string) returns(value1)
	%get register value and check for validity
	v:value1:=eval_expr(st,s,1,string$size(s))
	if value1$fetch_reloc(v) then
	      error_print(st,"register value relocatable,absolute 0 assumed",s)
	      return(value1$zero()) end
	if v > value1$create("15.",0) cor v < value1$zero() then
	      error_print(st,"register value not between 0 and 15,absolute 0 assumed",s)
	      return(value1$zero()) end
	return (v)
end get_reg

eval_expr = proc(st:symtab,s:string,l,h:int) returns(value1)
	%interface to parse_expr
	dummy:int
	v:value1
	v,dummy:=parse_expr(s,l,h,st)
	return(v)
end eval_expr

end line
-^  $ findc = proc(c:char, s:string, l,h:int) returns(int)

	%this proc is blind to anything between quotes
	%assumes escape codes interpreted only when between quotes
	%Returns ptr to found char or h+1

	quote:bool:=false
	while l<=h do
		if ~quote cand s[l]=c then break
		elseif quote cand s[l]='\\' then if l<h then l:=l+1 end
		elseif s[l]='\"' then quote:=~quote end
		l:=l+1
		end
	return(l)
end findc

print_symtab=proc(st:symtab) 
	f:file:=symtab$fetch_outfile(st)
	file$putc(f,'\p')
	file$putc(f,'\n')
	file$puts(f,"      Symbol Table")
	file$putc(f,'\n')
	file$putc(f,'\n')
	symtab$print(st)
end print_symtab


opcode_name = proc(s:string) returns (bool)

	if s = "a   +`   dd" then return (true)  end
	if s = "sub" then return (true)  end
	if s = "move" then return (true) end
	if s = "jrst" then return (true) end
	if s = "jsp" then return (true)  end
	if s = "came" then return (true) end
	if s = "camg" then return (true) end
	if s = "caml" then return (true) end
	if s = "camn" then return (true) end
	if s = "xct" then return (true)  end
	return (false)
end opcode_name


clear_invalid_chars = proc(st:symtab,s:string) returns (string)

	t:string:=""
	for p:int in int$from_to_by(1,string$size(s),1) do
	       if s[p]='\t' cor (' '<=s[p] cand s[p]<='~') then t:=string$append(t,s[p])
		else error_print(st,"invalid char in position "
					||int$unparse(p)||" ignored",s) end
		end
	return(t)
end clear_invalid_chars

flush_remaining_lines=proc(st:symtab,f:file,p:page)
	if file$eof(f) then return end
	error_print(st,"text following .end statement ignored","")
	while true do
		s:string:=file$gets(f,'\n')
				except when eof: return end
		page$put(p,"","","",s)
		end
end flush_remaining_lines

check_label = proc(st:symtab,l:string)
	if ~symtab$labelp(st,l) then
		error_print(st,"symbol already used - label ignored",l)
	elseif st[l]~=st["."] then
		error_print(st,"ASSEMBLER ERROR-phase error,lc reset to "||
				value1$v2s(st[l]),l)
		symtab$replace(st,".",st[l])
	else end except when key_not_found:
		error_print(st,"ASSEMBLER ERROR-label not found by pass1 ignored",l) end
end check_label

get_ascii = proc(st:symtab,s:string,l,h:int) returns (string)
	%returns a string with no escape codes
	%assumes s[l] follows the command name
	%assumes s[h] precedes the comment
	%gets the argument from s and interprets it
	v:string:="\\000" %default if no argument
	%look for opening quotes
	while l<=h cand (s[l]=' ' cor s[l]='\t') do l:=l+1 end
	if l<=h cand s[l]~='\"' then
		%find the start of the argument
		p:int:=l+1
		while p<=h cand s[p]~='\"' do p:=p+1 end
		error_print(st,"text before quotes ignored",string$substr(s,l,p-l))
		l:=p end
	if l>h then %never did find any quotes
		error_print(st,"argument missing,\\000 assumed",s)
		return( interpret(st,v) ) end
	%start looking for closing quotes
	p:int:=l+1
	while p<=h cand s[p]~='\"' do
		if s[p]='\\' cand p<h then p:=p+1 end
		p:=p+1
		end
	if p>h then error_print(st,"missing closing quotes assumed present",s) end
	%store the argument in v
	v:=string$substr(s,l+1,p-l-1)
	%check if there is anything after the argument
	p:=p+1
	while p<=h cand (s[p]=' ' cor s[p]='\t') do p:=p+1 end
	if p<=h then error_print(st,"text following closing quotes ignored",
						    string$substr(s,p,h-p+1)) end
	return( interpret(st,v) )
end get_ascii

interpret = proc(st:symtab,s:string) returns(string)
	if s="" then
		error_print(st,"\"\" not a valid argument,\\000 assumed","")
		return(string$c2s(char$i2c(0))) end
	l:int:=1
	h:int:=string$size(s)
	v:string:=""
	while l<=h do
		%l is the next char to be analised
		if s[l]='\\' then %interpret the escape code
			if l<h cand (s[l+1]='\"' cor s[l+1]='\\') then
			    v:=string$append(v,s[l+1])
			    l:=l+2
			else %numeric escape code
			    %find the code
			    p:int:=l+1
			    while p<=l+3 cand p<=h cand num(s[p]) do p:=p+1 end
			    c:string:=string$substr(s,l+1,p-l-1)
			    %errors ?
			    fill:string:=string$rest("000",p-l)
			    if fill~="" then 
			        error_print(st,
				   "invalid escape code,assume \\"||fill||c,"\\"||c) end
			    n:int:=int$parse(c)
			    if n>=128 then
				error_print(st,"ascii code too large,000 assumed",c)
				n:=0 end
			    v:=string$append(v,char$i2c(n))
			    l:=p end
		else
			v:=string$append(v,s[l])
			l:=l+1 end
		end
	return(v)
end interpret
+` #9 6   kwc;toppar
kwc;par
kwc;symtab
kwc;value1
urgz;asm
urgz;pass2
urgz;line
urgz;page
urgz;funct
urgz;reps
clusys;word
clusys;nheap
 6   "   �<���ble = proc(infname:string,outfname:string,errfname:string)
	inf:file
	if ""=infname then inf:= file$tyi()
		else inf:=file$open_read(infname)
		end
	errf:file
	if ""=errfname then errf:=file$tyo()
		else errf:=file$open_write (errfname)
		end
	outf:file
	if ""=outfname then outf:=file$tyo()
		else outf:=file$open_write (outfname)
		end
	st:symtab:=symtab$create()
	symtab$assign_files(st,inf,outf,errf)
	file$puts(errf,"PASS 1 ERROR MESSAGES\n\n")
	pass1(st)
	file$close(inf)
	inf:=file$open_read(infname)
	symtab$assign_files(st,inf,outf,errf)
	file$puts(errf,"\p\nPASS 2 ERROR MESSAGES\n\n")
	pass2(st)
	file$close(inf)
	file$close(outf)
	file$close(errf)
	return
end assemble"   A6   		if ~quote cand s[l]=c then break
		elseif quote cand s[l]='\\' then if l<h then l:=l+1 end
		elseif s[l]='\"' then quote:=~quote end
		l:=l+1
		end
	return(l)
end findc

print_symtab=proc(st:symtab) 
	f:file:=symtab$fetch_outfile(st)
	file$putc(f,'\p')
	file$putc(f,'\n')
	file$puts(f,"      Symbol Table")
	file$putc(f,'\n')
	file$putc(f,'\n')
	symtab$print(st)
end print_symtab


opcode_name = proc(s:string) returns (bool)

	if s = "aA6                                      