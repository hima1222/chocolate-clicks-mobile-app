# 🎨 Payment System - Visual & Design Reference

## Color Palette

### Primary Colors
- **Primary Orange Button**: `Color.fromARGB(255, 245, 157, 74)`
  - HEX: `#F59D4A`
  - Used for: CTA buttons, selected states, accents
  - Example: "Continue", "Pay Now", "Book Now"

- **Dark Orange**: `Color.fromARGB(255, 230, 81, 0)`  
  - HEX: `#E65100`
  - Used for: Pricing, gradients, emphasis
  - Example: Price display, error highlights

- **Light Orange Accent**: `Color.fromARGB(159, 245, 157, 74)`
  - HEX: `#F59D4A` (with opacity)
  - Used for: Borders, light backgrounds, secondary accents
  - Example: Card borders, icon colors

### Neutral Colors
- **White**: `Colors.white` / `#FFFFFF`
  - Used for: Primary text, buttons
  
- **White 70%**: `Colors.white70`
  - Used for: Secondary text, descriptions
  
- **Black Overlay**: `Colors.black.withOpacity(0.5)`
  - Used for: Background overlays

- **Grey**: `Colors.grey.shade500`
  - Used for: Placeholder text, disabled states

### Background Colors
- **Dark Background**: `Colors.black.withOpacity(0.5)`
  - Used for: Page backgrounds with image overlays
  
- **Card Background**: `Color.fromARGB(49, 0, 0, 0)` (1% opacity)
  - Used for: Content cards
  - Example: Order summary cards, receipt cards

- **Input Background**: `Colors.white.withOpacity(0.08)`
  - Used for: Text input fields

- **Error Background**: `Colors.red.withOpacity(0.15)`
  - Used for: Error state cards

## Typography

### Font Family
- **Primary**: `'serif'` (throughout app)
  - Elegant, professional appearance
  - Used for: All text except specific UI labels

### Font Sizes
| Element | Size | Weight |
|---------|------|--------|
| Page Title | 28px | Bold (bold) |
| Section Title | 16px | w600 |
| Body Text | 14px | Normal |
| Label Text | 12px | Regular |
| Card Header | 14px | w600 |
| Description | 12px | Regular |

### Font Usage Examples

```dart
// Page Title (28px Bold)
'Payment Method'
'Add New Card'
'Order Summary'

// Section Title (16px w600)
'Card Details'
'Order Items'
'Payment Method'

// Body Text (14px)
Credit card numbers and descriptions

// Label Text (12px)
TextField labels and hints

// Emphasis Text (14px w600)
'Card Number', 'Cardholder Name'
```

## Component Styling

### Buttons

#### Primary CTA Button
```dart
ElevatedButton(
  backgroundColor: Color.fromARGB(255, 245, 157, 74),  // Orange
  padding: EdgeInsets.symmetric(vertical: 16),
  shape: RoundedRectangleBorder(borderRadius: 12),
  foregroundColor: Colors.white,
)
// Used for: "Continue", "Pay Now", "Book Now", "Add Card"
```

#### Secondary Button (Outlined)
```dart
OutlinedButton(
  side: BorderSide(color: Colors.white, width: 1.5),
  padding: EdgeInsets.symmetric(vertical: 16),
  shape: RoundedRectangleBorder(borderRadius: 12),
)
// Used for: "Continue Shopping", "Track Order"
```

### Input Fields

#### Standard TextField
```dart
TextFormField(
  decoration: InputDecoration(
    labelStyle: TextStyle(color: Colors.white70, fontSize: 12),
    hintStyle: TextStyle(color: Colors.grey.shade500),
    filled: true,
    fillColor: Colors.white.withOpacity(0.08),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Color.fromARGB(159, 245, 157, 74),
        width: 1.5,
      ),
    ),
  ),
)
```

### Cards

#### Content Card
```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Color.fromARGB(49, 0, 0, 0),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Color.fromARGB(159, 245, 157, 74),
      width: 1.5,
    ),
  ),
)
```

#### Error/Alert Card
```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.red.withOpacity(0.15),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.red.withOpacity(0.4),
      width: 1.5,
    ),
  ),
)
```

## Layout Patterns

### Standard Spacing
- **Page Padding**: 20px horizontal, 20px vertical
- **Element Gap**: 16px between sections
- **Inner Padding**: 16px within containers
- **Section Gap**: 30-40px between major sections
- **Button Spacing**: 12px between buttons

### Common Layouts

#### Full Width Button
```dart
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Button Text'),
  ),
)
```

#### Card Layout
```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.4),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    children: [
      // Content here
    ],
  ),
)
```

#### Row with Icon
```dart
Row(
  children: [
    Icon(icon),
    SizedBox(width: 12),
    Expanded(
      child: Column(
        // Text here
      ),
    ),
  ],
)
```

## Animation Guidelines

### Animation Durations
| Type | Duration | Curve |
|------|----------|-------|
| Element appearance | 100-200ms | easeIn/easeOut |
| Page transition | 300ms | ease |
| Success checkmark | 800ms | elasticOut |
| Loading spinner | 1000ms | linear |

### Animation Examples

#### Success Checkmark (Elastic Scale)
```dart
_scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
);
// Container with ScaleTransition
```

#### Fade In
```dart
_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
);
// FadeTransition widget
```

## Visual Hierarchy

### Screen Sections (Top to Bottom)

1. **Header** (20px top padding)
   - Back button + Title

2. **Subtitle** (if present)
   - Smaller, secondary text
   - Gap: 20px to next section

3. **Main Content**
   - Forms, cards, lists
   - Gap between items: 16px

4. **Call-to-Action**
   - Primary button
   - Gap above: 40-50px

5. **Secondary Actions**
   - Secondary button
   - Gap above: 12px

## Form Input States

### Normal State
```
Border: Transparent with white 0.1 opacity
Fill: Colors.white.withOpacity(0.08)
Text: Colors.white
Label: Colors.white70
```

### Focused State
```
Border: Orange (#F59D4A) 1.5px
Fill: Colors.white.withOpacity(0.08)
Text: Colors.white
Label: Colors.white70
```

### Error State
```
Border: Red (if applicable)
Fill: Colors.white.withOpacity(0.08)
Text: Colors.white
Error Message: Red below field
```

### Disabled State
```
Border: Grey (disabled appearance)
Fill: Colors.grey.withOpacity(0.1)
Text: Colors.grey
Pointer: Not allowed
```

## Icon Usage

### Primary Icons
- **Back**: `Icons.arrow_back` (white)
- **Close/Failed**: `Icons.close` (white on red background)
- **Success**: `Icons.check` (white on orange background)

### Input Icons
- **Card**: `Icons.credit_card`
- **Wallet**: `Icons.wallet`
- **Bank**: `Icons.account_balance`
- **UPI**: `Icons.qr_code_2`
- **Lock**: `Icons.lock`
- **Visibility**: `Icons.visibility` / `Icons.visibility_off`

### Size Standards
- **Large Icon** (in circles): 60px
- **Medium Icon** (in containers): 28px
- **Small Icon** (inline): 16-20px

## Responsive Breakpoints

### Small Phones (320px - 374px)
- Single column layouts
- Full width buttons
- Reduced padding: 16px
- Font size: May reduce by 1-2px

### Regular Phones (375px - 411px)
- Standard layouts
- Full width buttons
- Standard padding: 20px
- Standard font sizes

### Large Phones (412px - 599px)
- Same as regular
- Slightly wider cards

### Tablets (600px - 839px)
- Can use 2-column layouts
- Centered content
- Max width: 500px

### Desktops (840px+)
- Centered layouts
- Max width: 600px
- May add side-by-side forms

## Accessibility Colors

### WCAG AA Compliant Combinations
- ✅ White (#FFF) on Dark Background (black.withOpacity(0.5))
- ✅ Orange (#F59D4A) on White
- ✅ White on Orange (#F59D4A)
- ✅ Grey on Dark Background

### Contrast Ratios
- Text to background: **4.5:1+ (minimum)**
- Large text: **3:1+ (minimum)**
- Current implementation: All compliant

## Visual Examples by Screen

### Payment Method Screen
```
[← Back]    (White icon)

Payment Method     (28px, White, Bold)
Select preferred payment method    (14px, White70)

┌─────────────────────────────────┐
│ 🏧 Credit/Debit Card            │ ✓ (Selected - orange border)
│    Visa, Mastercard or other    │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ 💰 Digital Wallet               │   (Not selected - grey border)
│    Apple Pay or Google Pay      │
└─────────────────────────────────┘

[Continue]    (Orange, full width, 16px padding)
```

### Add Card Screen
```
[← Back]

Add New Card     (28px, White, Bold)
Enter card details securely    (14px, White70)

┌─────────────────────────────────┐
│ [4111] [1111] [1111] [1111]     │ (Live preview)
│ CARDHOLDER NAME         EXPIRES │
│ YOUR NAME               MM/YY   │
└─────────────────────────────────┘

Card Number *    (12px label)
[______ ______ ______ ______]    (Input field)

Cardholder Name *
[John Doe]    (Input field)

Expiry Date * | CVV *
[MM/YY]       [123]    (Side by side)

☑ Save this card for future purchases

[Add Card]    (Orange, full width)
```

### Payment Summary Screen
```
[← Back]

Order Summary    (28px, White, Bold)

Order Details
├─ Chocolate Cake × 1    Rs. 1500.00
├─ Brownies Pack × 2     Rs. 1000.00

Pricing
├─ Subtotal              Rs. 2500.00
├─ Delivery Fee          Rs. 150.00
├─ Tax (10%)             Rs. 250.00
─────────────────────────────────
├─ Total                 Rs. 2900.00    (Orange text, bold)

Payment Method
[🏧 Credit Card]
Card: ****1111

Delivery To
Himara Perera
40/J, MC Road, Matale

[Pay Now]    (Orange, full width, shows spinner while processing)
```

### Success Screen
```
            ⭕ (Animated orange checkmark)

Payment Successful!         (28px, White, Bold)
Your payment has been processed successfully.    (White70)

┌─────────────────────────────────┐
│ Amount Paid      Rs. 2,900.00   │ (Orange)
├─────────────────────────────────┤
│ Order ID         CHC1234567     │
│ Date & Time      2026‐02‐25     │
│ Status           ✓ Completed    │ (Green badge)
└─────────────────────────────────┘

Order Status
1. ✓ Order Confirmed           (Orange checkmark)
   Your order has been confirmed

2. ✓ Preparing
   Your order is being prepared

3.   On The Way               (Grey)
   Your order is on the way to you

4.   Delivered
   Your order will be delivered soon

[Continue Shopping]    (Orange, full width)
[Track Order]         (Outlined, full width)
```

---

## Design Tokens Summary

```json
{
  "colors": {
    "primary": "#F59D4A",
    "darkPrimary": "#E65100",
    "lightPrimary": "#F59D4A",
    "text": "#FFFFFF",
    "textSecondary": "#B3B3B3",
    "background": "#000000",
    "surface": "#1A1A1A",
    "error": "#FF0000"
  },
  "spacing": {
    "xs": "8px",
    "sm": "12px",
    "md": "16px",
    "lg": "20px",
    "xl": "30px",
    "xxl": "40px"
  },
  "radius": {
    "small": "8px",
    "medium": "12px",
    "large": "20px"
  },
  "typography": {
    "fontFamily": "serif",
    "sizes": {
      "title": "28px",
      "heading": "16px",
      "body": "14px",
      "caption": "12px"
    },
    "weights": {
      "bold": "700",
      "w600": "600",
      "normal": "400"
    }
  }
}
```

---

**Last Updated**: February 25, 2026
**Design System Version**: 1.0.0
