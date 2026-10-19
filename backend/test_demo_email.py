import unittest
from unittest.mock import patch, MagicMock
from demo_lenders import deliver


class EmailTests(unittest.TestCase):
    def test_no_configuration_does_not_connect(self):
        with patch.dict('os.environ', {}, clear=True), patch('demo_lenders.smtplib.SMTP') as smtp:
            self.assertEqual(deliver('user@example.com', '[DEMO] Test', 'Demo'), 'preview_only')
            smtp.assert_not_called()

    def test_delivery_and_failure_are_explicit(self):
        config = dict(DEMO_SMTP_HOST='smtp.example.com', DEMO_EMAIL_FROM='project@example.com')
        with patch.dict('os.environ', config, clear=True), patch('demo_lenders.smtplib.SMTP') as smtp:
            connection = MagicMock()
            smtp.return_value.__enter__.return_value = connection
            self.assertEqual(deliver('user@example.com', '[DEMO] Test', 'Demo'), 'sent')
            connection.starttls.assert_called_once()
            message = connection.send_message.call_args.args[0]
            self.assertEqual(message['To'], 'user@example.com')
            self.assertEqual(message['From'], 'project@example.com')
            smtp.side_effect = OSError('offline')
            self.assertEqual(deliver('user@example.com', '[DEMO] Test', 'Demo'), 'failed')
