# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'LNCD Tools'
copyright = '2025, Will Foran'
author = 'Will Foran'
release = '1.0.0.20250731'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['sphinx.ext.autodoc', 'sphinx.ext.autosummary',
              'sphinx.ext.doctest', 'sphinx.ext.todo',
              'sphinx.ext.autosectionlabel',

              # failing: AttributeError: 'NoneType' object has no attribute '_sphinx_immaterial_synopsis'
              # 'sphinx_immaterial',

              'breathe', 'exhale']

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store', '.venv', 'doxygen']


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'piccolo_theme'

# html_theme = 'sphinx_immaterial'  # for ..code-annotatoins::

html_static_path = ['_static']

# -- Breathe/Doxygen
breathe_default_project = "doxy"
breathe_projects = {"doxy": "doxygen/xml/"}

# type defs will fail
# autodoc_mock_imports = ['nibabel','matplotlib', 'google-api-python-client', 'oauth2client']

exhale_args = {
    "containmentFolder":     "./other",
    "rootFileName":          "other.rst",
    "doxygenStripFromPath":  "..",
    # Heavily encouraged optional argument (see docs)
    "rootFileTitle":         "Other",
    # Suggested optional arguments
    "createTreeView":        True,
    "exhaleExecutesDoxygen": False  # True if sphinx-bootstrap-theme
}
