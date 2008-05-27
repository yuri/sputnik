Colors are typically encoded in software by their coordinates in the RGB (Red-Green-Blue) color space.  Unfortunately, the RGB color space is very
unintuitive and additionally certain principles of color harmony do not express themselves easily in RGB.  The HSL (Hue-Saturation-Lightness) color
space solves both of those problems.  This library allows you to work with colors in the HSL space, calculate harmonious patterns and then convert
the result to RGB.  (See [worqx.com](http://www.worqx.com/color/color_wheel.htm) for some background on color harmony.)

## The HSL Color Space

Colors are encoded in HSL by three values: Hue, Saturation and Lightness.

<center><img src="http://media.freewisdom.org/etc/hsv_triangle.png"/></center>

**Lightness** is just the opposite of darkness of the color.  White has lightness 1, black has lightness 0.  Other colors are inbetween:
**Saturation** is the intensity of color, which shows how far the color is from gray.  Here are the shades of red for different saturation and lightness:

<table>
 <tr>&nbsp;</tr>
 <tr><td colspan='11' style='text-align:center'>Lightness</td></tr>
 <tr><td>&nbsp</td><td>&nbsp</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.0</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.1</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.2</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.3</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.4</td>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.5</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.6</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.7</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.8</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.9</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">1.0</td>
</tr>
 <tr>
  <td rowspan='11' style='vertical-align:center'>Saturation</td>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.0</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #000000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #191919;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #333333;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #4c4c4c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #666666;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #999999;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b2b2b2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cbcbcb;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e5e5e5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fefefe;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.1</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #000000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #1c1616;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #382d2d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #544444;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #705b5b;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c7272;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a38e8e;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #baaaaa;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d1c6c6;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e8e2e2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fefefe;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.2</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #000000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #1e1414;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #3d2828;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #5b3d3d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #7a5151;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #996666;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ad8484;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #c1a3a3;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d6c1c1;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #eae0e0;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fffefe;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.3</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #000000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #211111;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #422323;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #633535;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #844747;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a55959;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b77a7a;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #c99b9b;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #dbbcbc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #eddddd;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #feffff;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.4</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #000000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #230f0f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #471e1e;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #6b2d2d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #8e3d3d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b24c4c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #c17070;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d19393;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e0b7b7;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #efdbdb;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fffefe;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.5</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #000000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #260c0c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #4c1919;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #722626;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #993232;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf3f3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc6565;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d88c8c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e5b2b2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f2d8d8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fffefe;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.6</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #000000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #280a0a;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #511414;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #7a1e1e;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #a32828;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc3232;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d65b5b;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e08484;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #eaadad;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f4d6d6;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fffefe;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.7</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #000000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #2b0707;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #560f0f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #821616;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #ad1e1e;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d82626;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e05151;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e87c7c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #efa8a8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f7d3d3;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fefefe;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.8</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #000000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #2d0505;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #5b0a0a;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #890f0f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #b71414;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e51919;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ea4747;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ef7575;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f4a3a3;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f9d1d1;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fffefe;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.9</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #000000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #300202;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #600505;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #910707;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #c10a0a;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f20c0c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f43d3d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f76d6d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f99e9e;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fccece;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fffefe;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">1.0</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #000000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #330000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #660000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #990000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; color: #ffffff; background: #cc0000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff0000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff3232;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fe6666;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff9898;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ffcbcb;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #fffefe;">&nbsp;</td>
 </tr>
</table>

**Hue** is the "color" of color: what makes "green" different from "red".  Hue can also be expressed as a number between 0 and 1, though this library uses the values from 0 to 360 instead.
Unlike lightness and saturdation, hue _loops_: the hue of 360 is actually the same color as hue of 0 (red).

<table>

 <tr><td colspan='11' style='text-align:center'>Saturation</td></tr>
 <tr><td>&nbsp;</td><td>&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">1.0</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.9</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.8</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.7</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.6</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.5</td>

<td style="width:40px; text-align: right; border: 1px solid gray;">0.4</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.3</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.2</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.1</td>
<td style="width:40px; text-align: right; border: 1px solid gray;">0.0</td>
 </tr>
 <tr>
  <td rowspan='37' width='100px' style='vertical-align:center'>Hue</td>

<td style="width:40px; text-align: right; border: 1px solid gray;">0</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff0000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f20c0c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e51919;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d82626;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc3232;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf3f3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b24c4c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a55959;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #996565;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c7272;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">10</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff2a00;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f2330c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e53b19;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d84326;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc4c32;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf553f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b25d4c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a56559;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #996e65;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c7672;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">20</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff5500;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f2590c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e55d19;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d86126;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc6632;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf6a3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b26e4c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a57259;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #997665;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c7b72;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">30</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff7f00;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f27f0c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e57f19;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d87f26;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc7f32;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf7f3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b27f4c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a57f59;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #997f65;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c7f72;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">40</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ffaa00;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f2a50c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e5a119;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d89d26;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc9932;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf943f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b2904c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a58c59;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #998865;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c8372;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">50</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ffd400;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f2cc0c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e5c319;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d8bb26;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ccb232;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bfaa3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b2a14c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a59959;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #999065;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c8872;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">60</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #feff00;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f2f20c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e5e519;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d8d826;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cbcc32;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bfbf3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b2b24c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a5a559;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #999965;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c8c72;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">70</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d4ff00;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cbf20c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #c3e519;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bad826;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b2cc32;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a9bf3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a1b24c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #99a559;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #909965;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #888c72;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">80</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a9ff00;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a5f20c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a1e519;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #9dd826;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #98cc32;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #94bf3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #90b24c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8ca559;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #889965;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #838c72;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">90</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7fff00;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7ff20c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7fe519;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7fd826;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7fcc32;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7fbf3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7fb24c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7fa559;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f9965;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f8c72;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">100</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #54ff00;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #59f20c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #5de519;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #61d826;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #65cc32;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #6abf3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #6eb24c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #72a559;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #769965;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7b8c72;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">110</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #2aff00;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #33f20c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3be519;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #44d826;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4ccc32;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #55bf3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #5db24c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #65a559;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #6e9965;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #768c72;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">120</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #00ff00;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0cf20c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #19e519;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #26d826;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #32cc32;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3fbf3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4cb24c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #59a559;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #659965;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #728c72;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">130</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #00ff2a;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0cf233;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #19e53b;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #26d844;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #32cc4c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3fbf55;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4cb25d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #59a565;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #65996e;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #728c76;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">140</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #00ff55;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0cf259;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #19e55d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #26d861;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #32cc66;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3fbf6a;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4cb26e;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #59a572;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #659977;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #728c7b;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">150</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #00ff7f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0cf27f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #19e57f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #26d87f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #32cc7f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3fbf7f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4cb27f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #59a57f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #65997f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #728c7f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">160</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #00ffaa;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0cf2a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #19e5a1;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #26d89d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #32cc99;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3fbf94;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4cb290;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #59a58c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #659988;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #728c83;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">170</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #00ffd4;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0cf2cc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #19e5c3;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #26d8bb;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #32ccb2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3fbfaa;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4cb2a1;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #59a599;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #659990;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #728c88;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">180</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #00feff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0cf2f2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #19e5e5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #26d8d8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #32cbcc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3fbfbf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4cb2b2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #59a5a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #659999;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #728c8c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">190</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #00d4ff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0ccbf2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #19c3e5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #26bad8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #32b2cc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3fa9bf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4ca1b2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #5999a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #659099;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #72888c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">200</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #00a9ff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0ca5f2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #19a1e5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #269dd8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3298cc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3f94bf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4c90b2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #598ca5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #658899;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #72838c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">210</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #007fff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0c7ff2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #197fe5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #267fd8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #327fcc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3f7fbf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4c7fb2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #597fa5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #657f99;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #727f8c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">220</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0054ff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0c59f2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #195de5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #2661d8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3265cc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3f6abf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4c6eb2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #5972a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #657699;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #727b8c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">230</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #002aff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0c33f2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #193be5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #2644d8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #324ccc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3f55bf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4c5db2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #5965a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #656e99;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #72768c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">240</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0000ff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #0c0cf2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #1919e5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #2626d8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3232cc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3f3fbf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4c4cb2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #5959a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #656599;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #72728c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">250</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #2a00ff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #320cf2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #3b19e5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4326d8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #4c32cc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #543fbf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #5d4cb2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #6559a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #6e6599;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #76728c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">260</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #5500ff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #590cf2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #5d19e5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #6126d8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #6632cc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #6a3fbf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #6e4cb2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7259a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #776599;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7b728c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">270</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f00ff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f0cf2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f19e5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f26d8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f32cc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f3fbf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f4cb2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f59a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f6599;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f728c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">280</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #aa00ff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a50cf2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a119e5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #9d26d8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #9932cc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #943fbf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #904cb2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c59a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #886599;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #83728c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">290</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d400ff;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cb0cf2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #c319e5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ba26d8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b232cc;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a93fbf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a14cb2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #9959a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #906599;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #88728c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">300</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff00fe;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f20cf2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e519e5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d826d8;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc32cb;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf3fbf;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b24cb2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a559a5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #996599;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c728c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">310</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff00d4;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f20ccb;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e519c3;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d826ba;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc32b2;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf3fa9;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b24ca1;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a55998;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #996590;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c7287;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">320</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff00a9;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f20ca5;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e519a1;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d8269d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc3298;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf3f94;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b24c90;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a5598c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #996588;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c7283;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">330</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff007f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f20c7f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e5197f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d8267f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc327f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf3f7f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b24c7f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a5597f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #99657f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c727f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">340</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff0054;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f20c59;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e5195d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d82661;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc3265;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf3f6a;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b24c6e;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a55972;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #996576;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c727b;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">350</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff002a;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f20c33;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e5193b;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d82644;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc324c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf3f55;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b24c5d;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a55965;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #99656e;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c7276;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
 <tr>

<td style="width:40px; text-align: right; border: 1px solid gray;">360</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #ff0000;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #f20c0c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #e51919;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #d82626;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #cc3232;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #bf3f3f;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #b24c4c;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #a55959;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #996565;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #8c7272;">&nbsp;</td>
<td style="width:40px; text-align: right; border: 1px solid gray; background: #7f7f7f;">&nbsp;</td>
 </tr>
</table>

## HSL Calculations with Colors

Creating a color in HSL space and converting it to RGB

    > require("colors")
    > c = colors.new(130, .8, 0.3) -- green, pretty saturated, somewhat dark
    > =tostring(c)
    #0f8923

<table>
 <tr><td width="100"></td><td width="160" style="background: #0f8923">&nbsp;</td></tr>
</table>

You can also create this color from it's RGB code:

    > require("colors")
    > c = colors.new("#0f8923") -- green, pretty saturated, somewhat dark
    > =tostring(c)
    #0f8923

The color converts to its RGB representation when forced into a string:

    > =c -- convert implicitly
    #0f8923

<table><tr><td width="100"></td><td width="160" style="background: #0f8923">&nbsp;</td></tr>
</table>

Accessing the HSL components:

    > print(c.H, c.S, c.L)
    130     0.8     0.3

Changing saturation:

    > =c:desaturate_by(.5) -- set saturation to saturation*.5
    #2d6b38
    
<table><tr><td width="100"></td><td width="160" style="background: #2d6b38">&nbsp;</td></tr>
</table>
    
    > =c:desaturate_to(.5) -- set saturation to .5
    #267233

<table><tr><td width="100"></td><td width="160" style="background: #267233">&nbsp;</td></tr>
</table>

Changing lightness:

    > =c:lighten_by(.5) -- set lightness to lightness*.5
    #14b72f

<table><tr><td width="100"></td><td width="160" style="background: #14b72f">&nbsp;</td></tr>
</table>

    > =c:lighten_to(.5) -- set lightness to .5
    #19e53b

<table><tr><td width="100"></td><td width="160" style="background: #19e53b">&nbsp;</td></tr>
</table>

Changing hue:

    > =c:hue_offset(180) -- shift hue by 180
    #890f75

<table><tr><td width="100"></td><td width="160" style="background: #890f75">&nbsp;</td></tr>
</table>

## Building Color Schemes

To build a color scheme, we usually start with a color, pick one or more matching colors, then derive shades and tints from them.  You might want to read up on color combinations at [worqx.com](http://www.worqx.com/color/combinations.htm
).

For a **monochromatic** color scheme, we'll just use the color we started with and tints and shades from it:

    > tints = c:tints(5) -- make five tints
    > for i,t in ipairs(tints) do print(t) end
    #16c934
    #3ee95a
    #7ef091
    #bef7c8
    #ffffff
    
<table>
 <tr>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #16c934">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #3ee95a">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #7ef091">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #bef7c8">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
</table>
    
    > shades = c:shades(5) -- make five shades
    > for i,s in ipairs(shades) do print(s) end
    #0c6e1c
    #095215
    #06370e
    #031b07
    #000000

<table>
 <tr>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #0c6e1c">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #095215">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #06370e">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #031b07">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #000000">&nbsp;</td>
 </tr>
</table>

For a **complimentary** scheme, we can use easily derive a complimentary color and its tints and shades:

    > ctints = c:complementary():tints(5) -- make five tints of the complimentary color
    > for i,t in ipairs(ctints) do print(t) end
    #c916ac
    #e93ecd
    #f07edd
    #f7beee
    #ffffff

<table>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #16c934">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #3ee95a">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #7ef091">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #bef7c8">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
 <tr>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #c916ac">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #e93ecd">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #f07edd">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #f7beee">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
</table>

For less contrast, though, we might want to stick with **neighboring** colors: e.g., +/- 60 degrees of the starting color:

    > n1, n2 = c:neighbors(60)  -- get neiboring colors: 60 degees up and down
    > for i,t in ipairs(n1:tints()) do print(t) end
    #16c98e
    #3ee9b0
    #7ef0ca
    #bef7e4
    #ffffff
    > for i,t in ipairs(n2:tints()) do print(t) end
    #52c916
    #77e93e
    #a4f07e
    #d1f7be
    #ffffff

<table>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #16c934">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #3ee95a">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #7ef091">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #bef7c8">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
 <tr>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #16acc9">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #3ecde9">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #7eddf0">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #beeef7">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
 <tr>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #acc916">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #cde93e">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ddf07e">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #eef7be">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
</table>

We could alternatively generate a split complementary color scheme:

    >  for i,t in ipairs(c1:tints()) do print(t) end
    #8e16c9
    #b03ee9
    #ca7ef0
    #e4bef7
    #ffffff
    > for i,t in ipairs(c2:tints()) do print(t) end
    #c91652
    #e93e77
    #f07ea4
    #f7bed1
    #ffffff

<table>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #16c934">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #3ee95a">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #7ef091">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #bef7c8">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
 <tr>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #8e16c9">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #b03ee9">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ca7ef0">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #e4bef7">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
 <tr>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #c91652">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #e93e77">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #f07ea4">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #f7bed1">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
</table>


Or a triadic one:

    > t1, t2 = c:triadic()
    > for i,t in ipairs(t1:tints()) do print(t) end
    #3416c9
    #5a3ee9
    #917ef0
    #c8bef7
    #ffffff
    > for i,t in ipairs(t2:tints()) do print(t) end
    #c93416
    #e95a3e
    #f0917e
    #f7c8be
    #ffffff

<table>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #16c934">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #3ee95a">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #7ef091">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #bef7c8">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
 <tr>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #3416c9">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #5a3ee9">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #917ef0">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #c8bef7">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
 <tr>
  <td width="100"></td>
  <td width="80" style="border:1px solid grey; background: #c93416">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #e95a3e">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #f0917e">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #f7c8be">&nbsp;</td>
  <td width="80" style="border:1px solid grey; background: #ffffff">&nbsp;</td>
 </tr>
</table>

