# Payment System Testing Guide

## Quick Start - Testing the Payment Flow

### 1. Start the App
```bash
flutter run
# Select: Chrome (web) or Windows (desktop)
```

### 2. Navigate to Products
- Tap "Get Started" on landing page
- Click "Shop Here" on welcome screen
- Or select any product category (Cake, Brownies, Cookies)

### 3. Test Payment Scenario

#### Scenario A: Successful Payment (80% chance)
1. Click "Buy Now" on any product
2. Select "Credit/Debit Card" as payment method
3. Click "Continue"
4. **Fill Card Details** (Test Card):
   - Card Number: `4111 1111 1111 1111` (will auto-format)
   - Cardholder Name: `John Doe`
   - Expiry: `12/25`
   - CVV: `123`
5. Click "Add Card"
6. Review order summary
7. Click "Pay Now"
8. Wait 3 seconds (payment processing animation)
9. **See Success Screen** with:
   - Animated checkmark
   - Order ID and receipt
   - Order status timeline

#### Scenario B: Failed Payment (20% chance)
1. If payment fails, you'll see the failure screen
2. Can either:
   - Try "Another Payment Method" (returns to payment method selection)
   - "Continue Shopping" (returns to welcome screen)

### 4. Test Form Validation

#### Test Invalid Card Number
1. Card Number Field: Type `1234` (less than 16 digits)
2. Click "Add Card"
3. **Expected**: Error message "Card number must be 16 digits"

#### Test Invalid Name
1. Cardholder Name: Type `John` (no last name)
2. Click "Add Card"
3. **Expected**: Error message "Please enter first and last name"

#### Test Invalid Expiry
1. Expiry Field: Type `1225` (without slash)
2. Should auto-format when you exit field, but click "Add Card" if not
3. **Expected**: Error or auto-formatting

#### Test Invalid CVV
1. CVV Field: Try typing letters (should only accept digits)
2. Leave as empty
3. Click "Add Card"
4. **Expected**: Error message "CVV is required"

### 5. Test Other Payment Methods

#### Digital Wallet
1. Click "Buy Now" on product
2. Select "Digital Wallet"
3. Click "Continue"
4. Directly goes to Payment Summary
5. Complete payment with "Pay Now"

#### Bank Transfer
1. Click "Buy Now" on product
2. Select "Bank Transfer"
3. Click "Continue"
4. Directly goes to Payment Summary
5. Would show bank details in real implementation

#### UPI Payment
1. Click "Buy Now" on product
2. Select "UPI Payment"
3. Click "Continue"
4. Directly goes to Payment Summary
5. Would show UPI QR code in real implementation

## Visual Testing Checklist

### Layout & Alignment
- [ ] All screens fit properly on mobile/tablet/desktop
- [ ] Text is readable with consistent font sizes
- [ ] Buttons are properly aligned and sized
- [ ] Spacing is consistent throughout

### Colors & Branding
- [ ] Orange primary color (245, 157, 74) used for CTAs
- [ ] Body text is white on dark backgrounds
- [ ] Secondary text (white70) for descriptions
- [ ] Borders and highlights use accent orange

### Animations
- [ ] Card number formats smoothly (spaces every 4 digits)
- [ ] Success checkmark animates smoothly (elastic effect)
- [ ] Fade-in animation for content
- [ ] Loading spinner on "Pay Now" button

### Form Behavior
- [ ] Focus moves to next field when digit limit reached
- [ ] Validation messages appear clearly
- [ ] Form disables submit button when invalid
- [ ] Error messages are helpful and specific

## Automated Test Scenarios

### Test Pattern: Payment Success
```
1. Open app
2. Navigate to product
3. Click "Buy Now" → Select "Card" → "Continue"
4. Fill: 4111111111111111, John Doe, 12/25, 123
5. Submit → Review → "Pay Now"
6. Wait 3 seconds
7. Verify: Success screen appears
```

### Test Pattern: Form Validation
```
1. Navigate to "Add Card"
2. Try different invalid inputs:
   - Empty fields
   - Short card number
   - No last name
   - Wrong expiry format
   - Non-numeric CVV
3. Verify: Appropriate error messages appear
4. Verify: Submit button remains disabled
```

### Test Pattern: Navigation Flow
```
1. From Welcome → "Buy Now" → Payment Method
2. From Payment Method → various methods tested
3. From Summary → success/failure redirection
4. Verify: Back buttons work (disable during processing)
5. Verify: No unintended navigation loops
```

## Performance Testing

### Mobile (Chrome DevTools):
1. Open Chrome DevTools (F12)
2. Go to Device Toolbar (Ctrl+Shift+M)
3. Select iPhone/Android preset
4. Test performance:
   - Smooth scrolling
   - Fast button responses
   - No layout shifts
   - Animations are 60fps

### Desktop:
1. Run on Windows platform
2. Verify full-screen rendering
3. Test form input responsiveness
4. Check animation frame rates

## Accessibility Testing

### Keyboard Navigation
- [ ] Tab through form fields (order should be: card → name → expiry → cvv)
- [ ] Enter submits form
- [ ] Escape can cancel (not on payment processing)

### Screen Reader (NVDA/JAWS)
- [ ] Labels are associated with inputs
- [ ] Button text is descriptive
- [ ] Error messages are announced
- [ ] Loading state is announced

### Color Contrast
- [ ] White text on dark background (WCAG AA compliant)
- [ ] Orange buttons have sufficient contrast
- [ ] Error messages readable

## Edge Cases to Test

### Network Issues (Future Enhancement)
- [ ] Timeout handling
- [ ] Retry logic
- [ ] Offline mode behavior

### Multi-Device Testing
- [ ] Small phone (320px width)
- [ ] Regular phone (375px width)
- [ ] Tablet (768px width)
- [ ] Desktop (1200px+ width)

### Language Support (Future)
- [ ] RTL languages (if supported)
- [ ] Special characters in names
- [ ] Currency formatting

## Bug Report Template

**If you find an issue, please report:**

```
Title: [Brief description of issue]

Environment:
- Device: [phone/tablet/desktop]
- Browser/Platform: [Chrome/Edge/Windows]
- Screen Size: [wxh]

Steps to Reproduce:
1. [First step]
2. [Second step]
3. [etc.]

Expected Result:
[What should happen]

Actual Result:
[What actually happened]

Screenshots: [If applicable]

Severity: [Critical/High/Medium/Low]
```

## Success Metrics

The payment system is working correctly if:

✅ Form validation prevents invalid submissions
✅ Card number auto-formats with spaces
✅ Card preview updates in real-time
✅ Payment processing shows loading state
✅ Success/failure screens display correctly
✅ Navigation flow is smooth
✅ Animations are smooth (no jank)
✅ All error messages are helpful
✅ Back buttons work when expected
✅ No breaking changes to existing screens

## Troubleshooting

### Payment always fails
- This is normal! Success rate is 80%, so about 1 in 5 times should fail
- On failure, try "Another Payment Method" option

### Form validation not working
- Ensure you're using valid inputs
- Check browser console (F12) for JavaScript errors
- Try hot reload: Press 'r' in terminal

### Animations stuttering
- Check device performance
- Try using a more powerful device/simulator
- Reduce other background processes

### Navigation not working
- Verify all routes are in `app.dart`
- Check flutter analyze for missing imports
- Try `flutter clean` then `flutter pub get`

### Card preview not updating
- Try typing in the cardholder name field
- The preview should update in real-time
- If not, check browser DevTools console for errors

---

**Ready to start testing?** 
1. Navigate to any product by clicking "Buy Now"
2. Follow the payment flow
3. Test with OTP registration first (code: 123456)
4. Report any issues found

Happy testing! 🚀
