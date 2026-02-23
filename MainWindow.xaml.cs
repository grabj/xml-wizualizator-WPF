using System;
using System.ComponentModel;
using System.Windows;
using Microsoft.Web.WebView2.Core;

namespace XmlWizualizator
{
    public partial class MainWindow : Window
    {
        private MainViewModel? _viewModel;

        public MainWindow()
        {
            InitializeComponent();
            
            // Ustaw DataContext
            _viewModel = new MainViewModel();
            DataContext = _viewModel;
            
            InitializeWebView();
            
            // Subskrybuj zmiany
            if (_viewModel != null)
            {
                _viewModel.PropertyChanged += ViewModel_PropertyChanged;
                _viewModel.PrintRequested += ViewModel_PrintRequested;
                _viewModel.PrintPreviewRequested += ViewModel_PrintPreviewRequested;
            }
        }

        private async void InitializeWebView()
        {
            try
            {
                webView.DefaultBackgroundColor = System.Drawing.Color.White;
                
                await webView.EnsureCoreWebView2Async(null);

                // Jeśli w ViewModelu jest już wynik transformacji — wyświetl go po inicjalizacji
                if (_viewModel != null && !string.IsNullOrEmpty(_viewModel.TransformedOutput))
                {
                    DisplayTransformationResult(_viewModel.TransformedOutput);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Błąd inicjalizacji WebView2: {ex.Message}", 
                    "Błąd", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ViewModel_PropertyChanged(object? sender, PropertyChangedEventArgs e)
        {
            if (e.PropertyName == nameof(MainViewModel.TransformedOutput) && _viewModel != null)
            {
                DisplayTransformationResult(_viewModel.TransformedOutput);
            }
        }

        private void ViewModel_PrintRequested(object? sender, EventArgs e)
        {
            PrintWebView();
        }

        private void ViewModel_PrintPreviewRequested(object? sender, EventArgs e)
        {
            OpenPrintPreview();
        }

        public void DisplayTransformationResult(string htmlContent)
        {
            if (string.IsNullOrEmpty(htmlContent))
                return;

            // Jeśli WebView2 jest gotowy — nawiguj od razu
            if (webView?.CoreWebView2 != null)
            {
                webView.NavigateToString(htmlContent);
                return;
            }

            // Jeśli WebView2 nie jest jeszcze zainicjalizowany — podpisz się jednorazowo na zdarzenie inicjalizacji
            void Handler(object? s, CoreWebView2InitializationCompletedEventArgs args)
            {
                try
                {
                    if (args.IsSuccess)
                    {
                        webView?.NavigateToString(htmlContent);
                    }
                }
                finally
                {
                    webView.CoreWebView2InitializationCompleted -= Handler;
                }
            }

            webView.CoreWebView2InitializationCompleted += Handler;
        }

        private async void PrintWebView()
        {
            try
            {
                if (webView?.CoreWebView2 != null)
                {
                    // Przygotuj domyślną nazwę pliku
                    string defaultFileName = "wizualizacja";
                    if (!string.IsNullOrEmpty(_viewModel?.SelectedXmlPath))
                    {
                        string xmlFileName = System.IO.Path.GetFileNameWithoutExtension(_viewModel.SelectedXmlPath);
                        defaultFileName = $"wizualizacja_{xmlFileName}";
                    }

                    // Otwórz okno dialogowe "Zapisz jako"
                    var saveFileDialog = new Microsoft.Win32.SaveFileDialog
                    {
                        Filter = "Plik PDF (*.pdf)|*.pdf",
                        Title = "Zapisz wizualizację jako PDF",
                        FileName = $"{defaultFileName}.pdf",
                        DefaultExt = ".pdf"
                    };

                    if (saveFileDialog.ShowDialog() == true)
                    {
                        // Zapisz do PDF
                        var printSettings = webView.CoreWebView2.Environment.CreatePrintSettings();
                        printSettings.ShouldPrintBackgrounds = true;
                        printSettings.ShouldPrintHeaderAndFooter = false;
                        
                        bool success = await webView.CoreWebView2.PrintToPdfAsync(
                            saveFileDialog.FileName, 
                            printSettings);

                        if (success && _viewModel != null)
                        {
                            _viewModel.StatusMessage = $"PDF zapisany: {System.IO.Path.GetFileName(saveFileDialog.FileName)}";
                            
                            // Opcjonalnie: zapytaj czy otworzyć plik
                            var result = MessageBox.Show(
                                $"Plik PDF został zapisany:{Environment.NewLine}{saveFileDialog.FileName}{Environment.NewLine}{Environment.NewLine}Czy chcesz otworzyć plik?",
                                "PDF zapisany",
                                MessageBoxButton.YesNo,
                                MessageBoxImage.Information);
                            
                            if (result == MessageBoxResult.Yes)
                            {
                                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                                {
                                    FileName = saveFileDialog.FileName,
                                    UseShellExecute = true
                                });
                            }
                        }
                        else if (_viewModel != null)
                        {
                            _viewModel.StatusMessage = "Błąd podczas zapisywania PDF";
                            MessageBox.Show(
                                "Nie udało się zapisać pliku PDF.",
                                "Błąd",
                                MessageBoxButton.OK,
                                MessageBoxImage.Error);
                        }
                    }
                    else if (_viewModel != null)
                    {
                        _viewModel.StatusMessage = "Zapisywanie anulowane";
                    }
                }
                else
                {
                    MessageBox.Show(
                        "WebView2 nie jest jeszcze zainicjalizowany.",
                        "Błąd",
                        MessageBoxButton.OK,
                        MessageBoxImage.Warning);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"Błąd podczas zapisywania PDF:{Environment.NewLine}{Environment.NewLine}{ex.Message}",
                    "Błąd zapisu",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
                
                if (_viewModel != null)
                {
                    _viewModel.StatusMessage = $"Błąd zapisu PDF: {ex.Message}";
                }
            }
        }

        private void OpenPrintPreview()
        {
            try
            {
                if (webView?.CoreWebView2 != null)
                {
                    // Otwarcie podglądu wydruku poprzez wykonanie JavaScript
                    webView.CoreWebView2.ExecuteScriptAsync("window.print();");
                    
                    if (_viewModel != null)
                    {
                        _viewModel.StatusMessage = "Podgląd wydruku otwarty";
                    }
                }
                else
                {
                    MessageBox.Show(
                        "WebView2 nie jest jeszcze zainicjalizowany.",
                        "Błąd",
                        MessageBoxButton.OK,
                        MessageBoxImage.Warning);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"Błąd podczas otwierania podglądu:{Environment.NewLine}{Environment.NewLine}{ex.Message}",
                    "Błąd podglądu",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
                
                if (_viewModel != null)
                {
                    _viewModel.StatusMessage = $"Błąd podglądu: {ex.Message}";
                }
            }
        }

        private void WebView_NavigationCompleted(object sender, CoreWebView2NavigationCompletedEventArgs e)
        {
            if (webView?.CoreWebView2?.Profile != null)
            {
                // Wymuś jasny motyw
                webView.CoreWebView2.Profile.PreferredColorScheme = CoreWebView2PreferredColorScheme.Light;
            }
        }

        protected override void OnClosed(EventArgs e)
        {
            if (_viewModel != null)
            {
                _viewModel.PropertyChanged -= ViewModel_PropertyChanged;
                _viewModel.PrintRequested -= ViewModel_PrintRequested;
                _viewModel.PrintPreviewRequested -= ViewModel_PrintPreviewRequested;
            }
            base.OnClosed(e);
        }
    }
}