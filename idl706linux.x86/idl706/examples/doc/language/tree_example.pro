;  $Id: //depot/idl/IDL_70/idldir/examples/doc/language/tree_example.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
;;$File Tree_Example.pro
;;
;; DESCRIPTION:
;;
;;	This file contains example routines that call the TREE_XXXX routines
;;	contained in the file idl_tree.pro. To run this program, enter the
;;	following commands at the IDL prompt:
;;
;;	IDL> .run idl_tree
;;	IDL> tree_example
;;
;;	The TREE_NEW, TREE_TRAVERSE, and TREE_DELETENODE routines are
;;	found in the file idl_tree.pro.
;;
;;
;; MODIFICATION HISTORY:
;;	March 1994,  -KDB	Initial coding
;;	August 1996,  -KDB	Updated to use pointers
;;
;;============================================================================

PRO CmpData, d1, d2, result
;;
;; Do the comparison of the data

  result= (d1.data lt d2.data)*(-1) + (d1.data eq d2.data)*0  $
			+ (d1.data gt d2.data)*1
END
;;============================================================================

PRO CmpTime, d1, d2, result
;;
;; Do the comparison of the time data
  result= (d1.time lt d2.time)*(-1) + (d1.time eq d2.time)*0  $
                        + (d1.time gt d2.time)*1
END

;;============================================================================

PRO PrintStruct, Data
;;
;; Print the data

   print,"Time: ", Data.time, " Data: ", Data.data

END

;;===========================================================================

PRO Tree_Example

;; Make a structure to hold our fake data. With pointers, this can
;; be any IDL type.

   Cnt = 10

   DATATYPE = {time:0d0, data:0.0}

   MyData = replicate(DATATYPE, Cnt)

;; Create some data

   MyData.data = randomn(Seed, Cnt)

;; Put some time tags on the data

   MyData.time = Systime(1)*randomu(Seed, Cnt)

;; Now lets make a tree that will store the data in time order and one
;; that holds the data in data order.  "Tree_new" is found in the file
;; idl_tree.pro:

   Tree_new, DataTree, 'CmpData'
   Tree_new, TimeTree, 'CmpTime'

;; Go through and place the data into the trees:

   for i = 0, Cnt-1 do begin
      Tree_Insert, TimeTree, MyData(i)
      Tree_Insert, DataTree, MyData(i)
   endfor

;; Print out the trees

   Print, "Here is the tree sorted by TIME values:"
   Tree_Traverse, TimeTree,  'PrintStruct', /INORDER

   Print, "Here is the tree sorted by DATA values:", Format='(/,A)'
   Tree_Traverse, DataTree, 'PrintStruct', /INORDER

;;
   Print, "Press any key to continue...", Format='(/,A,$)'
   a=Get_Kbrd(1)
;
;; Lets search for some data
;
   Print, ""
;
;;Search for the fourth data value:
;
   Print, "Searching for the fourth data value:", MyData(3)
;
   pData = Tree_Search(TimeTree, MyData(3))
;
   if(not PTR_VALID(pData))then 	$
	print,"Data Not Found"				$
   else BEGIN
	print, "Data Found, Value :", *pData
   ENDelse
;
;; Now delete some nodes in the tree
;
   Print,""
   Print, "Deleting the node that contains:", MyData(3)

   Tree_DeleteNode, DataTree, MyData(3)
   Tree_DeleteNode, TimeTree, MyData(3)
;
;; Now do another search for the node we just deleted
;
   Print, ""
;
   Print, "Now performing a search for the node we just deleted..."
   Print, "Searching for :", MyData(3)
;
   pData = Tree_Search(TimeTree, MyData(3))
;
   if(not PTR_VALID(pData(0)))then   $
        print,"Data Not Found"                          $
   else BEGIN
        print, "Data Found, Value :", *pData
   ENDelse
;
   Print,""
;
   Print, "Now we also delete the node containing the second data value."
   Print, "Deleting node :", MyData(1)
;
   Tree_DeleteNode, DataTree, MyData(1)
   Tree_DeleteNode, TimeTree, MyData(1)
;
   Print, ""
   Print, "Finally, we print the resulting trees..."
   Print, "Sorted by TIME values:", Format='(/,A)'
   Tree_Traverse, TimeTree, 'printStruct', /INORDER
;
   Print, "Sorted by DATA values:", Format='(/,A)'
   Tree_Traverse, DataTree, 'printStruct', /INORDER
;
;; Now delete the trees
;
   Tree_Delete, DataTree
   Tree_Delete, TimeTree
;
END
