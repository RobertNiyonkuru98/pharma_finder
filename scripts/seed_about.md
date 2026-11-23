# Seed the About screen content

The "About MediMatch Rwanda" screen reads a single Firestore document at
`app_config/about`. Nothing in the app writes that document, so seed it once
from the Firebase Console.

## Steps

1. Open the Firebase Console for project **medimatch-b4737**.
2. Go to **Firestore Database → Data**.
3. Create a collection named `app_config` (if it does not exist yet).
4. Add a document with the ID **`about`**.
5. Switch the editor to **JSON** mode and paste the payload below, then save.

## Payload

```json
{
  "appName": "MediMatch Rwanda",
  "version": "1.2.0",
  "tagline": "Kigali Health Tech Initiative",
  "supportPhone": "112",
  "supportEmail": "support@medimatch.rw",
  "privacyUrl": "https://medimatch.rw/privacy",
  "aboutBody": "MediMatch helps Rwandans find verified pharmacies, clinics and hospitals that accept their insurance. Search by distance, confirm stock and opening hours, and keep an emergency passport with your blood type, allergies and next of kin ready for first responders. Data is stored securely in your own account and is never shared without your consent."
}
```

## Field reference

| Field          | Type   | Used by                                   |
| -------------- | ------ | ----------------------------------------- |
| `appName`      | string | About screen title                        |
| `version`      | string | About screen version pill, settings row   |
| `tagline`      | string | About screen subtitle, settings row       |
| `supportPhone` | string | About screen tappable `tel:` row          |
| `supportEmail` | string | About screen tappable `mailto:` row       |
| `privacyUrl`   | string | About screen tappable privacy link        |
| `aboutBody`    | string | About screen body copy (plain text)       |

Every field is optional: the app shows "About information is being updated.
Please try again later." when the document is missing or unreadable.

## Security rules

`app_config` is readable by any signed-in user and writable only by admins
(Console / Admin SDK). Deploy the rules once with:

```bash
firebase deploy --only firestore:rules
```
