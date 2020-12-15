import os

const night_theme_xml* = 
    """<application> 
    <component name="LafManager" autodetect="false">
        <laf class-name="com.intellij.ide.ui.laf.darcula.DarculaLaf" />
    </component>
</application>"""

const day_color_scheme_xml* =
    """<application>
  <component name="EditorColorsManagerImpl">
    <global_color_scheme name="IntelliJ Light" />
  </component>
</application>"""

const night_color_scheme_xml* =
    """<application>
  <component name="EditorColorsManagerImpl">
    <global_color_scheme name="Darcula copy" />
  </component>
</application>"""

const day_theme_xml* = 
    """<application>
  <component name="LafManager" autodetect="false">
    <laf class-name="com.intellij.ide.ui.laf.IntelliJLaf" themeId="JetBrainsLightTheme" />
  </component>
</application>"""

let path_configs = os.getEnv("HOME") / ".config" / "JetBrains"

proc pycharm_set_theme*(xml_text: string) =
    for dirpath in (path_configs / "PyCharm*").walk_dirs():
        let filepath =  dirpath / "options" / "laf.xml"
        writeFile(filepath, xml_text)
        echo "wrote into ", filepath


proc pycharm_set_color_scheme*(xml_text: string) =
    for dirpath in (path_configs / "PyCharm*").walk_dirs():
        let filepath =  dirpath / "options" / "colors.scheme.xml"
        writeFile(filepath, xml_text)
        echo "wrote into ", filepath