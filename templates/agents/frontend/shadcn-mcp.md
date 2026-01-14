# ⚠️ shadcn/ui MCP - OBBLIGATORIO

## REGOLA #1: USA SEMPRE L'MCP

Questo progetto ha **shadcn MCP server** configurato.

**NON creare MAI componenti UI manualmente. USA L'MCP.**

---

## Come Funziona

L'MCP server (`npx shadcn@latest mcp`) gestisce i componenti automaticamente.

### Per aggiungere componenti:

```
"Aggiungi Button con shadcn MCP"
"Usa MCP shadcn per Dialog e Select"
"Ho bisogno di Tabs - installa con shadcn"
```

L'MCP installerà automaticamente il componente in `components/ui/`.

---

## Componenti Disponibili

| Categoria | Componenti |
|-----------|------------|
| **Input** | Button, Input, Textarea, Select, Checkbox, Radio, Switch, Slider |
| **Display** | Card, Badge, Avatar, Alert, Progress, Skeleton, Separator |
| **Overlay** | Dialog, Sheet, Popover, Tooltip, Dropdown Menu, Context Menu |
| **Navigation** | Tabs, Navigation Menu, Breadcrumb, Pagination, Command |
| **Data** | Table, Data Table, Calendar, Date Picker |
| **Layout** | Scroll Area, Resizable, Collapsible, Accordion |
| **Forms** | Form, Label, Input OTP |

**Docs complete:** https://ui.shadcn.com/docs/components

---

## ❌ VIETATO - Non fare MAI questo

```tsx
// ❌ NON creare bottoni custom
const CustomButton = ({ children }) => (
  <button className="bg-blue-500 hover:bg-blue-600 px-4 py-2 rounded">
    {children}
  </button>
)

// ❌ NON creare modal/dialog custom
<div className="fixed inset-0 bg-black/50">
  <div className="modal-content">...</div>
</div>

// ❌ NON creare select custom
<div className="dropdown">
  <div className="dropdown-trigger">...</div>
</div>

// ❌ NON scrivere Tailwind per componenti base
<button className="inline-flex items-center justify-center rounded-md text-sm...">
```

---

## ✅ CORRETTO - Fai sempre così

```tsx
// ✅ Usa Button di shadcn
import { Button } from "@/components/ui/button"
<Button variant="default" size="sm">Click me</Button>
<Button variant="outline">Cancel</Button>
<Button variant="destructive">Delete</Button>

// ✅ Usa Dialog di shadcn
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter
} from "@/components/ui/dialog"

<Dialog open={open} onOpenChange={setOpen}>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Titolo</DialogTitle>
    </DialogHeader>
    {/* contenuto */}
    <DialogFooter>
      <Button>Salva</Button>
    </DialogFooter>
  </DialogContent>
</Dialog>

// ✅ Usa Select di shadcn
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

<Select value={value} onValueChange={setValue}>
  <SelectTrigger>
    <SelectValue placeholder="Seleziona..." />
  </SelectTrigger>
  <SelectContent>
    <SelectItem value="opt1">Opzione 1</SelectItem>
    <SelectItem value="opt2">Opzione 2</SelectItem>
  </SelectContent>
</Select>
```

---

## Checklist Prima di Scrivere UI

1. [ ] Il componente esiste in shadcn? → **Usa quello**
2. [ ] Devo installarlo? → **Chiedi all'MCP**
3. [ ] È già installato in `components/ui/`? → **Importalo**
4. [ ] Non esiste in shadcn? → **Solo allora crea custom**

---

## MCP Configuration

In `.claude/settings.json`:
```json
{
  "mcpServers": {
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    }
  }
}
```
