/*
 * Copyright (c) 2011 Parkour Visions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 * LinkedList.m
 * author: emancebo
 * 2/16/11
 */

#import "LinkedList.h"
@implementation LinkedList

- (id) init {
	if (self = [super init]) {
		head = NULL;
		tail = NULL;
		mCount=0;
	}
	return self;
}

- (LinkedListNode*) getHead {
	return head;
}

- (LinkedListNode*) getTail {
	return tail;
}

// add to end of list
- (void) add:(id)element {	
	LinkedListNode *node = [[LinkedListNode alloc] initWithData:element];
	
	if (head == NULL) {
		head = node;
	}
	
	if (tail != NULL) {
		tail.next = node;
		node.prev = tail;
	}
	
	++mCount;
	tail = node;
}

- (void) add:(id)element afterNode:(LinkedListNode*)node {
	LinkedListNode *newNode = [[LinkedListNode alloc] initWithData:element];
	
	if (node == nil) {
		// new node becomes the head
		LinkedListNode *oldHead = head;
		head = newNode;
		
		// forward links
		head.next = oldHead;
		if (oldHead != nil) {
			oldHead.prev = head;
		}
	}
	else {
		LinkedListNode *newNextNode = [node next];
		
		// back links
		node.next = newNode;
		newNode.prev = node;
		
		// forward links
		newNode.next = newNextNode;
		if (newNextNode != nil) {
			newNextNode.prev = newNode;
		}
		else {
			// move tail if there is no next node
			tail = newNode;
		}
	}
	++mCount;
}

// remove given LinkedListNode
- (void) remove:(LinkedListNode*)node {
	
	LinkedListNode *prev = node.prev;
	LinkedListNode *next = node.next;
	
	// element is head
	if (prev == NULL && next != NULL) {
		next.prev = NULL;
		head = next;
	}
	// element is tail
	else if (prev != NULL && next == NULL) {
		prev.next = NULL;
		tail = prev;
	}
	// element is in the middle
	else if (prev != NULL && next != NULL) {
		next.prev = prev;
		prev.next = next;
	}
	// element is the only element
	else {
		head = NULL;
		tail = NULL;
	}
	
	--mCount;
	[node release];
}

- (void) removeFirst:(id)element {
	for (LinkedListNode *n=head; n != NULL; n = n.next) {
		if (n.data == element) {
			[self remove:n];
			break;
		}
	}
}

- (void) clear {
	LinkedListNode *n = head;
	while (n != NULL) {
		LinkedListNode *nodeToRemove = n;
		n = n.next;
		[self remove:nodeToRemove];
	}
}

- (void) dealloc {
	LinkedListNode *n = head;
	while (n != NULL) {
		LinkedListNode *nodeToDealloc = n;
		n = n.next;
		[nodeToDealloc release];
	}
	[super dealloc];
}

- (int) count {
	return mCount;
}

@end
