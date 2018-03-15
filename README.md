# SyntaxColoring

A simple open-source library showing dynamic syntax coloring on an iOS and MacOS text editor, along with a sample class showing syntax coloring on a C-style language.

## License

Licensed under the open-source BSD license:

Copyright 2017 William Woody

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Usage:

This defines a single view class, `SCTextView` for iOS, along with a single protocol, `SCSyntaxScanner`. The SCTextView class provides functionality for syntax coloring (by calling the SCSyntaxScanner class), and also provides for automatic indentation of text.

### SCTextView

Interfaces

- (UITextView *)textView;

Provides access to the underlying text view for obtaining and setting text.

- (void)setSyntaxScanner:(id<SCSyntaxScanner>)scanner;

Provides a mechanism for updating the syntax scanner. This will also recolor all of the text according to the new scanner.

### SCSyntaxScanner

Interfaces

- (void)scanString:(NSMutableAttributedString *)str hintRange:(NSRange)range;

This method is called when text changes, with the range of the updated text. Your syntax scanner can use the hint string to determine the range of text to be scanned, and updates the properties on the provided attributed string.

There is an example of a class which does this in the private `SCCScanner` class.

## Notes:

Currently this is an incomplete implementation. In the future additional interfaces will be provided which makes this a much more robust system for entering code on the Mac and on iOS.
