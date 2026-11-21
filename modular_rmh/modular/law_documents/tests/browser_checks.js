/* Executed in a real headless browser against the shipped SCOM HTML/CSS/JS. */
(function () {
  var passed = [];
  function check(condition, name) {
    if (!condition) throw new Error(name);
    passed.push(name);
  }
  function update(data) { rmhScomUpdate(JSON.stringify(data)); }
  var fixture = { language: "ru", mode: "normal", laws: [],
    decrees: [{id:"ignored",text:"SECRET DECREE MUST NOT APPEAR",text_en:"SECRET DECREE MUST NOT APPEAR"}]
  };
  for (var i = 0; i < 16; i++) {
    fixture.laws.push({id:"entry_"+i,text:"Русский закон "+i+" — соблюдать мир и порядок. ".repeat(8),
      text_en:i === 1 ? "" : "English law "+i+" — keep the peace and order. ".repeat(8)});
  }
  fixture.laws[0].text = "<img src=x onerror=alert(1)> & <script>bad()</script>";
  try {
    var initialText = "Первый закон: 10% tax + A+B & хлеб";
    check(document.getElementById("scom-text").textContent.indexOf(initialText) >= 0, "inline initial data decodes form-encoded spaces and keeps literal plus and percent");
    // Captured from native BYOND 516 url_encode(json_encode(data)), not encodeURIComponent.
    var nativeEncoded = "%7b%22language%22%3a%22ru%22%2c%22mode%22%3a%22normal%22%2c%22laws%22%3a%5b%7b%22id%22%3a%22bootstrap%22%2c%22text%22%3a%22%5cu041f%5cu0435%5cu0440%5cu0432%5cu044b%5cu0439+%5cu0437%5cu0430%5cu043a%5cu043e%5cu043d%3a+10%25+tax+%2b+A%2bB+%26+%5cu0445%5cu043b%5cu0435%5cu0431%22%2c%22text_en%22%3a%22First+law%3a+10%25+tax+%2b+A%2bB+%26+bread%22%7d%5d%7d";
    check(nativeEncoded.indexOf("+") >= 0 && /%2b/i.test(nativeEncoded), "native fixture distinguishes encoded spaces from literal plus");
    rmhScomInitial(nativeEncoded);
    check(document.getElementById("scom-text").textContent.indexOf(initialText) >= 0, "native DM initial fixture keeps spaces, percent, plus, ampersand and Cyrillic");
    fixture.laws[0].text += " 10% tax A+B 100% & Кириллица 😀";
    update(fixture);
    check(document.getElementById("scom-text").textContent.indexOf("10% tax A+B 100% & Кириллица 😀") >= 0, "already-decoded output preserves percent, plus, ampersand and Unicode");
    var box = document.getElementById("scom-text");
    check(!document.getElementById("scom-edition"), "laws window has no edition label");
    check(!document.getElementById("scom-title"), "laws window has no heading label");
    check(!document.getElementById("laws-tab") && !document.getElementById("decrees-tab") &&
      typeof window.rmhScomPage === "undefined", "laws window has no document tabs or decree route");
    check(box.textContent.indexOf("SECRET DECREE") < 0, "unrelated decree data cannot appear in the laws reader");
    check(box.textContent.indexOf("<img") >= 0 && box.querySelectorAll("img,script").length === 0, "legal text is rendered as plain text");
    document.getElementById("scom-language").click();
    check(box.textContent.indexOf("English law") >= 0, "English toggle displays manual translation");
    check(box.textContent.indexOf("Русский закон 1") >= 0 &&
      box.textContent.indexOf("английский перевод не заполнен") >= 0, "missing English falls back to original with a label");
    box.scrollTop = 80;
    fixture.laws[2].text_en = "Updated English edition. ".repeat(12);
    update(fixture);
    check(box.scrollTop === 80 && box.textContent.indexOf("Updated English edition") >= 0, "publication keeps language and scroll position");
    fixture.language = "en";
    update(fixture);
    check(document.getElementById("scom-close").title === "Close" &&
      document.documentElement.lang === "en" && box.textContent.indexOf("translation not supplied") >= 0,
      "character preference updates already-open SCOM interface labels");
    fixture.language = "ru";
    update(fixture);
    check(document.getElementById("scom-close").title === "Закрыть" &&
      document.documentElement.lang === "ru" && box.lang === "en" &&
      box.textContent.indexOf("Updated English edition") >= 0 && box.scrollTop === 80,
      "changing interface language preserves manual document choice and scroll");
    document.getElementById("scom-language").click();
    check(box.textContent.indexOf("Русский закон") >= 0, "Russian toggle returns to the source laws");
    var first = box.firstChild;
    [["normal","rgb(51, 126, 193)"],["muted","rgb(193, 59, 54)"],["garrison","rgb(212, 128, 40)"]].forEach(function (state) {
      rmhScomMode(state[0]);
      var thumb = getComputedStyle(box, "::-webkit-scrollbar-thumb");
      check(thumb.backgroundColor === state[1] && thumb.borderRadius === "0px",
        state[0] + " scrollbar has the correct colour and square corners");
    });
    check(box.firstChild === first && box.scrollTop === 80, "mode update preserves law nodes and scroll position");
    check(getComputedStyle(box).scrollbarColor === "auto", "native scrollbar colours do not override rectangular styling");
    function key(name, code, ctrl) {
      var event = new KeyboardEvent("keydown", {key:name, keyCode:code, ctrlKey:ctrl !== false, bubbles:true, cancelable:true});
      document.dispatchEvent(event);
      return event;
    }
    function size() { return parseFloat(getComputedStyle(box).fontSize); }
    function wheel(delta, ctrl) {
      var event = new WheelEvent("wheel", {deltaY:delta, ctrlKey:ctrl, bubbles:true, cancelable:true});
      box.dispatchEvent(event);
      return event;
    }
    var frame = document.getElementById("scom").getBoundingClientRect();
    var originalSize = size();
    check(key("+",187).defaultPrevented && size() > originalSize, "Ctrl plus enlarges text and prevents page zoom");
    key("-",189);
    check(size() === originalSize, "Ctrl minus reduces text");
    key("Add",107);
    key("Subtract",109);
    check(size() === originalSize, "numpad plus and minus control text size");
    check(wheel(-120,true).defaultPrevented && size() > originalSize, "Ctrl wheel up enlarges text");
    check(wheel(120,true).defaultPrevented && size() === originalSize, "Ctrl wheel down reduces text");
    check(!wheel(-120,false).defaultPrevented && !key("+",187,false).defaultPrevented &&
      size() === originalSize, "unmodified wheel and keys keep normal behavior");
    key("+",187);
    var enlarged = size();
    document.getElementById("scom-language").click();
    update(fixture);
    rmhScomMode("muted");
    check(size() === enlarged, "text size survives language, publication and mode changes");
    var nextFrame = document.getElementById("scom").getBoundingClientRect();
    check(nextFrame.width === frame.width && nextFrame.height === frame.height,
      "text zoom keeps the pixel frame size");
    key("0",48);
    check(size() === originalSize, "Ctrl zero resets text size");
    for (var n=0;n<60;n++) key("+",187);
    check(size() === 36, "maximum text size is bounded");
    for (var n=0;n<60;n++) key("-",189);
    check(size() === 12, "minimum text size is bounded");
    key("0",48);
    // Leave the same mode as the earlier hover regression expects.
    rmhScomMode("garrison");
    var bar = document.getElementById("scom-drag");
    var barRect = bar.getBoundingClientRect();
    check(barRect.height > 0 && barRect.bottom <= document.getElementById("scom-language").getBoundingClientRect().top,
      "drag area covers the upper pixel band without covering controls");
    var savedRatio = Object.getOwnPropertyDescriptor(window,"devicePixelRatio");
    var savedBridge = window.BYOND;
    var savedCef = window.cef_to_byond;
    var savedRaf = window.requestAnimationFrame;
    var savedCancel = window.cancelAnimationFrame;
    var frames = {};
    var sequence = 0;
    var writes = [];
    var lateReply = null;
    var deferPosition = false;
    var ratio = window.devicePixelRatio || 1;
    function mouse(target, type, x, y, button, buttons) {
      target.dispatchEvent(new MouseEvent(type, {bubbles:true,cancelable:true,
        screenX:x,screenY:y,button:button || 0,buttons:buttons || 0}));
    }
    function flushDrag() {
      var batch = frames;
      frames = {};
      Object.keys(batch).forEach(function (id) { batch[id](); });
    }
    window.requestAnimationFrame = function (fn) { frames[++sequence] = fn; return sequence; };
    window.cancelAnimationFrame = function (id) { delete frames[id]; };
    window.BYOND = {
      winget:function (id, property) {
        if (id !== "rmh_scom_laws" || property !== "pos") throw new Error("unexpected winget");
        return {then:function (ok) {
          if (deferPosition) lateReply = ok;
          else ok({pos:{x:100,y:200}});
        }};
      },
      winset:function (id, params) { writes.push({id:id,pos:params.pos}); }
    };
    try {
      mouse(box,"mousedown",200,300,0,1);
      mouse(bar,"mousedown",200,300,2,2);
      mouse(document,"mousemove",220,325,0,1);
      flushDrag();
      check(writes.length === 0, "text and right clicks do not move the window");
      mouse(bar,"mousedown",200,300,0,1);
      mouse(document,"mousemove",210,310,0,1);
      mouse(document,"mousemove",220,325,0,1);
      check(writes.length === 0, "drag movements are batched until an animation frame");
      flushDrag();
      check(writes.length === 1 && writes[0].id === "rmh_scom_laws" &&
        writes[0].pos === Math.round(100+20*ratio)+","+Math.round(200+25*ratio),
        "drag moves the native SCOM window with DPI-scaled deltas");
      mouse(document,"mouseup",220,325,0,0);
      mouse(document,"mousemove",250,360,0,1);
      flushDrag();
      check(writes.length === 1, "mouseup ends dragging");
      deferPosition = true;
      mouse(bar,"mousedown",200,300,0,1);
      mouse(document,"mouseup",205,305,0,0);
      lateReply({pos:{x:500,y:600}});
      mouse(document,"mousemove",250,360,0,1);
      flushDrag();
      check(writes.length === 1, "late winget reply cannot revive an ended drag");
      deferPosition = false;
      Object.defineProperty(window,"devicePixelRatio",{value:2,configurable:true});
      mouse(bar,"mousedown",200,300,0,1);
      mouse(document,"mousemove",210,315,0,1);
      flushDrag();
      check(writes[writes.length-1].pos === "120,230", "drag scales CSS mouse deltas for a simulated double-DPI client");
      mouse(document,"mouseup",210,315,0,0);
      if (savedRatio) Object.defineProperty(window,"devicePixelRatio",savedRatio);
      else delete window.devicePixelRatio;
      mouse(bar,"mousedown",200,300,0,1);
      mouse(document,"mousemove",210,315,0,1);
      window.dispatchEvent(new Event("blur"));
      var stoppedCount = writes.length;
      mouse(document,"mousemove",250,360,0,1);
      flushDrag();
      check(writes.length === stoppedCount, "window blur ends dragging and cancels pending frames");
      window.BYOND = null;
      var calls = [];
      window.cef_to_byond = function (url) { calls.push(url); };
      mouse(bar,"mousedown",200,300,0,1);
      rmhScomDragPosition({pos:{x:50,y:70}});
      mouse(document,"mousemove",210,315,0,1);
      flushDrag();
      mouse(document,"mouseup",210,315,0,0);
      check(calls[0] === "byond://winget?callback=rmhScomDragPosition&id=rmh_scom_laws&property=pos" &&
        calls[1] === "byond://winset?id=rmh_scom_laws&pos="+Math.round(50+10*ratio)+","+Math.round(70+15*ratio),
        "legacy client bridge moves only the SCOM window without server Topics");
    } finally {
      window.dispatchEvent(new Event("blur"));
      if (savedRatio) Object.defineProperty(window,"devicePixelRatio",savedRatio);
      else delete window.devicePixelRatio;
      window.BYOND = savedBridge;
      window.cef_to_byond = savedCef;
      window.requestAnimationFrame = savedRaf;
      window.cancelAnimationFrame = savedCancel;
    }
    var close = document.getElementById("scom-close");
    close.dispatchEvent(new MouseEvent("mouseenter"));
    check(document.getElementById("scom").className.indexOf("is-glowing") >= 0, "hover lights the grille");
    close.dispatchEvent(new MouseEvent("mouseleave"));
    check(document.getElementById("scom").className.indexOf("is-glowing") < 0 &&
      document.getElementById("scom").getAttribute("data-mode") === "garrison", "leaving clears grille glow and retains the scrollbar state");
    check(close.getAttribute("href").indexOf(";close=1") >= 0, "grille click targets the close-only Topic");
    document.documentElement.setAttribute("data-tests", JSON.stringify({passed:passed}));
  } catch (error) {
    document.documentElement.setAttribute("data-tests", JSON.stringify({passed:passed,error:String(error)}));
  }
}());
