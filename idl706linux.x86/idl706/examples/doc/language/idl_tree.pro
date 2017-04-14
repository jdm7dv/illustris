;  $Id: //depot/idl/IDL_70/idldir/examples/doc/language/idl_tree.pro#2 $

;  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
;       rights reserved.
; 
;;$File idl_tree.pro
;;
;; DESCRIPTION:
;;
;;	This set of routines is used to build a simple tree data structure
;;	using IDL pointers.
;;
;;
;; MODIFICATION HISTORY:
;;	March 1994,  -KDB	Initial coding
;;	August 1996,  -KDB	Updated to use pointers
;;
;;===========================================================================
;;$ Procedure Tree_New

PRO Tree_New, Tree, cmp_func

;; PURPOSE:
;;	Initializes an IDL tree structure
;;
;; PARAMETERS:
;;	tree		- The new tree data structure
;;
;;	cmp_proc	- The comparison procedure for the tree data
;;			  Since the data depends on the user, the
;;		 	  user must supply a procedure that has the
;;		          following format:
;;
;;			    cmp_func,d1,d2, result
;;
;;			    result = -1  if d1 < d2
;;				      0  if d1 = d2
;;				      1  if d1 > d2
;;

;; If cmp_func is undefined (i.e., a null string) return:

   if(strtrim(cmp_func, 2) eq '')then begin
	Message, "Data Compairson procedure undefined, aborting", /CONTINUE

	Return
   ENDif

;; Make sure the tree data structure is defined:

   TreeType = {treetype, left:ptr_new(), right:ptr_new(), data:ptr_new()}

;; Make a header for the tree, using anonymous structures:

   tree = { cnt:0l, cmp:cmp_func, pHead:ptr_new()}

end
;;=========================================================================

FUNCTION Tree_NewNode, Data


;; PARAMETERS:
;;	Data	- The data value that will be placed in a node
;;
;; Create a new tree node, insert the data and return the pointer:

   Tmp = {treetype}
   tmp.data = ptr_new(data)
   return, ptr_new(tmp)
END
;---------------------------------------------------------------------------
pro  Tree_insert, Tree, Data

;; See if Data is defined, Else return an error:

   if(N_Elements(Data) eq 0)then BEGIN
 	message, "Data value undefined",/continue
	return
   ENDif

;  Do we have any nodes yet?

   if(Tree.pHead eq ptr_new())then $
       tree.pHead = Tree_NewNode(Data) $
   else $
       _Tree_Insert, Tree, Data, Tree.pHead
end
;;==========================================================================

PRO _Tree_Insert, Tree, Data, pNode

;; PURPOSE:
;;	This procedure is used to add a new node to the tree specified by
;;  	the structure Tree. The procedure will recurses on itself until
;;	the correct insert location is found on the tree, then it
;;      inserts the node and returns.
;;
;; PARAMETERS:
;;	Tree	- A tree struct
;;
;;	Data	- The data to be put in the tree
;;
;;	pNode   - Pointer to the current node. If this is null, insert
;;		  node here.
;;
;; Use the comparison function for the data to see what do to:

   Call_Procedure, Tree.cmp, Data, *(*pNode).data, result

   if( result(0) le 0)then BEGIN
	if(ptr_valid((*pNode).left))then $ ; continue traverse
 	   _Tree_Insert, Tree, Data, (*pNode).left $
	else begin
	    (*pNode).left = Tree_NewNode(Data)
	    tree.cnt = tree.cnt+1;
        endelse
   ENDif else BEGIN
	if(ptr_valid((*pNode).right)) then $
 	   _Tree_Insert, Tree, Data, (*pNode).right $
	else begin
	    (*pNode).right = Tree_NewNode(Data)
	    tree.cnt = tree.cnt+1;
        endelse
   ENDelse

END

;;============================================================================
FUNCTION _Tree_Search, Tree, Data, pNode

;; PURPOSE:
;;	Searches the tree for a match and returns a null ptr if there is no
;;	match and a pointer if there is a match. This function is recursive.
;;
;; PARAMETERS:
;;	Tree	- The Tree to search
;;
;;	Data	- The data to search for
;;
;;	pNode   - Pointer to node 

   forward_function _tree_search

   if(N_Elements(Data) eq 0) then BEGIN
      Message, "Data value undefined", /CONTINUE
      Return, ptr_new()
   ENDif
   
   if(not PTR_VALID(pNode)) then $
      Return, ptr_new()

;  See if we have a match

   Call_Procedure, Tree.cmp, Data, *(*pNode).data, cmp_res
   
   if(cmp_res lt 0)then 				$
       return, _Tree_Search(Tree, Data, (*pNode).left)   $
   else if(cmp_res gt 0)then 				$
       return, _Tree_Search(Tree, Data, (*pNode).right)	$
   else	$
       return, (*pNode).data

END
;---------------------------------------------------------------------------
function Tree_Search, Tree, Data

   return, _Tree_Search(Tree, Data, Tree.pHead)
end
;---------------------------------------------------------------------------
pro Tree_DeleteNode, Tree, Data

    _Tree_DeleteNode, Tree, Data, Tree.pHead
end
;;============================================================================

PRO _Tree_DeleteNode, Tree, Data, pNode

;; PURPOSE:
;;	Deletes the first node if finds that contains Data. This routine
;;	recurses.
;;
;; PARAMETERS:
;;	Tree	- The tree you are Deleting from (structure)
;;
;;	Data	- The data that is to be deleted (structure)
;;
;;	pNode   - pointer to node

   if(N_Elements(Data) eq 0)then BEGIN
      Message, "Data value undefined", /CONTINUE
      Return
   ENDif

   if (not PTR_VALID(pNode) ) then BEGIN
       Message, "Data not found", /CONTINUE
       Return
   ENDif

;; Do we match

   Call_Procedure, Tree.cmp, Data, *(*pNode).data, cmp_res

   if(cmp_res lt 0)then $
      _Tree_DeleteNode, Tree, Data, (*pNode).left $
   else if(cmp_res gt 0)then $
      _Tree_DeleteNode, Tree, Data, (*pNode).right $
   else BEGIN	; we have a match

      l_valid = PTR_VALID((*pNode).left)
      r_valid = PTR_VALID((*pNode).right)

      if(not l_valid and not r_valid )then begin

      ; No children, delete the node
	ptr_free, (*pNode).data
	ptr_free, pNode

      endif else if(l_valid and r_valid)then begin

     ;; Both children are *valid* so we need to find the next smallest
     ;; child. This is the child that is the farthest left branch of the
     ;; current right child:

	pParent  = pNode
	pCurrent = (*pNode).right

     ;; Go down the left side of the right branch until there are no more
     ;; valid pointers:

        While( PTR_VALID((*pCurrent).left))do BEGIN
           pParent  = pCurrent
	   pCurrent = (*pParent).left
        ENDwhile

     ;; Replace the current node's data with data from the node
     ;; we are *splicing* in:

	ptr_free, (*pNode).data
	(*pNode).data = (*pCurrent).data

        if(pParent eq pNode)then $
           (*pNode).right = (*pCurrent).right 	$
        else $
	   (*pParent).left = (*pCurrent).right

	ptr_free, pCurrent
     endif else BEGIN

     ;; Only have one child. Clean up node and move up the child to
     ;; pNode

        if(l_valid)then 		$
	   pKill = (*pNode).left	$
        else				$
	   pKill= (*pNode).right
        ptr_free, (*pNode).data
	*pNode = *pKill
  	ptr_free, pKill	
     ENDelse
   ENDelse
END
;---------------------------------------------------------------------------
pro Tree_Traverse, Tree, Proc, INORDER=INORDER, 	$
		   PREORDER=PREORDER, POSTORDER=POSTORDER

   _Tree_Traverse, Proc, Tree.pHead, INORDER=INORDER, 	$
		   PREORDER=PREORDER, POSTORDER=POSTORDER
end
;;=====================================================================

PRO _Tree_Traverse, Proc, pNode , INORDER=INORDER, 	$
		   PREORDER=PREORDER, POSTORDER=POSTORDER

;; PURPOSE:
;;	This function recursivly traverses the tree in the selected order
;;  	applying the given procedure to each node.
;;
;; PARAMETERS:
;;	Proc	- Name of the procedure to apply to each node
;;
;;	pNode	- pointer to current node
;;
;; KEYWORDS:
;;	INORDER    - Do an inorder traversal
;;
;;	PREORDER   - Do a preorder traversal
;;
;;	POSTORDER  - Do a postorder traversal

   if(not PTR_VALID(pNode))then $
	Return

   if(Keyword_Set(PREORDER))then begin
      Call_Procedure, Proc, *(*pNode).data
      _Tree_Traverse, Proc, (*pNode).left , /PREORDER
      _Tree_Traverse, Proc, (*pNode).right, /PREORDER
   endif else if( Keyword_Set(POSTORDER))then begin
      _Tree_Traverse, Proc, (*pNode).left,  /POSTORDER
      _Tree_Traverse, Proc, (*pNode).right, /POSTORDER
      Call_Procedure, Proc, *(*pNode).data
   endif else begin
      _Tree_Traverse, Proc, (*pNode).left , /INORDER
      Call_Procedure, Proc, *(*pNode).data
      _Tree_Traverse, Proc, (*pNode).right, /INORDER
   endelse
end
;---------------------------------------------------------------------------
pro Tree_Delete, Tree

    _Tree_Delete, Tree.pHead
end
;;============================================================================
PRO _Tree_Delete, pNode

;; PURPOSE:
;; 	This procedure is used to delete all of the nodes in the tree.
;;	This is just a postorder traversal of the tree. This is done
;;	Recursivly.
;;
;; PARAMETER:
;;	pNode - The current node.


   if(not PTR_VALID(pNode))then $
	Return


   _Tree_Delete, (*pNode).left
   _Tree_Delete, (*pNode).right

   ptr_free, (*pNode).data
   ptr_free, pNode
end


