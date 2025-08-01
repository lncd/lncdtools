Documenting
===========

Docs built with ``Makefile``

.. code-block:: shell

   uv run sphinx-build -M html "." "_build"


Doxygen
+++++++

.. digraph::

   "filter" -> "Doxygen"  -> "Breathe" -> "Exhale" -> "Sphinx";


* breathe translates xml to rst for sphinx.
* Exhale writes to a specified file to generate stucture that ``.. doxygenindex`` otherwise does not preserve.
   * that file (``other/other.rst`` here) is includes in a ``.. toctree::``, likely at top level ``index.rst``

Perl
----

``doxygen-filter-perl`` provides a source filter to map to ``C++``, inhereting an object oriented documentation structure.

  * Use `package` in perl scripts to set the class name.

  * POD documentation should be under package but above `__END__`

     * below `__END__` goes to `main`

     * `=head ... =cut` gets inserted into docs of whatever function or package is preceeding


Doxyfile modifications are like

.. code::

   FILE_PATTERNS          = *.pl *.pm \
   ...
   EXTENSION_MAPPING      = pl=C++ pm=C++ \
   ...
   FILTER_PATTERNS        = *.pl=doxygen-filter-perl *.pm=doxygen-filter-perl \


