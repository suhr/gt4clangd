"
I am an LSP model for clangd, the C language server: https://clangd.llvm.org/

clangd ships with the LLVM toolchain. Install it with your system package manager, for example `apt install clangd`, `brew install llvm` or `nix profile install nixpkgs#clang-tools`, and make the `clangd` executable available on the `PATH`.

GtLSPClangdModel onDirectory: '/path/to/project' asFileReference

clangd reads the compile commands from compile_commands.json. Generate that file before you start the model, for example with `bear -- make` or with `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`. Without it clangd falls back to a heuristic command line, and cross-file features stay imprecise.

I handle the files with the extensions in GtLSPClangdModel class>>#extensions. The language identifier of clangd is 'cpp' (or 'c' for a plain C file); I use 'cpp' as the default of the client.
"
Class {
	#name : 'GtLSPClangdModel',
	#superclass : 'GtLSPDirectoryModel',
	#category : 'Gt4Clangd-Model',
	#package : 'Gt4Clangd',
	#tag : 'Model'
}

{ #category : 'accessing' }
GtLSPClangdModel class >> extensions [
	"clangd handles the extensions of C, C++ and Objective-C sources and headers."

	^ '*.c;*.cc;*.cpp;*.cxx;*.c++;*.h;*.hh;*.hpp;*.hxx;*.h++;*.inc'
]

{ #category : 'accessing' }
GtLSPClangdModel class >> initialize [
	"https://clangd.llvm.org/"

	"clangd ships with the LLVM toolchain. Install it with the package manager of the system, for example:
		apt install clangd
		brew install llvm
		nix profile install nixpkgs#clang-tools"

	self
		executable: (Smalltalk os isWindows ifTrue: [ 'clangd.exe' ] ifFalse: [ 'clangd' ]).
	self arguments: #()
]

{ #category : 'accessing' }
GtLSPClangdModel class >> languageType [
	"clangd uses one language identifier for both C and C++, and answers different diagnostics when it is wrong."

	^ 'cpp'
]

{ #category : 'accessing' }
GtLSPClangdModel class >> styler [
	^ CParser gtStyler
]

{ #category : 'accessing' }
GtLSPClangdModel >> diffSplitter [
	^ GtSmaCCDiffSplitter new scannerClass: CScanner
]

{ #category : 'search' }
GtLSPClangdModel >> gtClassSearch: aSearch [
	<gtSearch>
	| kind |
	kind := (GtLSPSymbolKindEnum enum: 'Class') value.
	^ aSearch list
		priority: 10;
		title: 'Classes';
		items: [ self allSymbolsStream select: [ :each | each kind = kind ] ];
		itemName: [ :item | item symbolName ];
		wantsToDisplayOnEmptyQuery: false;
		filterBySubstring
]

{ #category : 'search' }
GtLSPClangdModel >> gtEnumSearch: aSearch [
	<gtSearch>
	| kind |
	kind := (GtLSPSymbolKindEnum enum: 'Enum') value.
	^ aSearch list
		priority: 11;
		title: 'Enums';
		items: [ self allSymbolsStream select: [ :each | each kind = kind ] ];
		itemName: [ :item | item symbolName ];
		wantsToDisplayOnEmptyQuery: false;
		filterBySubstring
]

{ #category : 'search' }
GtLSPClangdModel >> gtFieldSearch: aSearch [
	<gtSearch>
	| kind |
	kind := (GtLSPSymbolKindEnum enum: 'Field') value.
	^ aSearch list
		priority: 15;
		title: 'Fields';
		items: [ self allSymbolsStream select: [ :each | each kind = kind ] ];
		itemName: [ :item | item symbolName ];
		wantsToDisplayOnEmptyQuery: false;
		filterBySubstring
]

{ #category : 'search' }
GtLSPClangdModel >> gtFunctionSearch: aSearch [
	<gtSearch>
	| kind |
	kind := (GtLSPSymbolKindEnum enum: 'Function') value.
	^ aSearch list
		priority: 13;
		title: 'Functions';
		items: [ self allSymbolsStream select: [ :each | each kind = kind ] ];
		itemName: [ :item | item symbolName ];
		wantsToDisplayOnEmptyQuery: false;
		filterBySubstring
]

{ #category : 'search' }
GtLSPClangdModel >> gtMethodSearch: aSearch [
	<gtSearch>
	| kind |
	kind := (GtLSPSymbolKindEnum enum: 'Method') value.
	^ aSearch list
		priority: 14;
		title: 'Methods';
		items: [ self allSymbolsStream select: [ :each | each kind = kind ] ];
		itemName: [ :item | item symbolName ];
		wantsToDisplayOnEmptyQuery: false;
		filterBySubstring
]

{ #category : 'search' }
GtLSPClangdModel >> gtNamespaceSearch: aSearch [
	<gtSearch>
	| kind |
	kind := (GtLSPSymbolKindEnum enum: 'Namespace') value.
	^ aSearch list
		priority: 12;
		title: 'Namespaces';
		items: [ self allSymbolsStream select: [ :each | each kind = kind ] ];
		itemName: [ :item | item symbolName ];
		wantsToDisplayOnEmptyQuery: false;
		filterBySubstring
]

{ #category : 'search' }
GtLSPClangdModel >> gtVariableSearch: aSearch [
	<gtSearch>
	| kind |
	kind := (GtLSPSymbolKindEnum enum: 'Variable') value.
	^ aSearch list
		priority: 16;
		title: 'Variables';
		items: [ self allSymbolsStream select: [ :each | each kind = kind ] ];
		itemName: [ :item | item symbolName ];
		wantsToDisplayOnEmptyQuery: false;
		filterBySubstring
]

{ #category : 'server messages' }
GtLSPClangdModel >> installMessageHandlers [
	lspClient
		on: 'textDocument/publishDiagnostics'
		as: GtLSPPublishDiagnosticsParamsStructure
		send: #publishDiagnostics:
		to: self
]

{ #category : 'server messages' }
GtLSPClangdModel >> publishDiagnostics: aParams [
	(self fileForUri: aParams uri)
		ifNotNil: [ :file | file diagnostics: aParams diagnostics ]
]
