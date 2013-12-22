lib-JBD
=======

Contains JBD::Core and JBD::Tempo modules, which I use on my website.

[My Main Website](http://www.joelbdalley.com)<br/>
[My Running Site](http://tempo.joelbdalley.com)

lib-JBD is copyright &copy; Joel Dalley 2013.<br/>
lib-JBD is distributed under the same license as Perl itself.<br/>
For more details, see the full text of the license in the file LICENSE.

Notes
=====

For quote-unquote security (in a couple web scripts), I have git-ignored one file: `JBD::Tempo::Passkey`, which has the following structure:

```perl
package JBD::Tempo::Passkey; our $KEY = 'super-duper-secret';
```
