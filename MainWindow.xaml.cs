using System;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using Microsoft.Web.WebView2.Core;
using DataFormats = System.Windows.DataFormats;
using DragDropEffects = System.Windows.DragDropEffects;
using DragEventArgs = System.Windows.DragEventArgs;

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
                _viewModel.BatchPdfRequested += ViewModel_BatchPdfRequested;
            }
        }

        private void MainGrid_DragOver(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
            {
                var files = e.Data.GetData(DataFormats.FileDrop) as string[];
                if (files != null && files.Any(f =>
                        Path.GetExtension(f).Equals(".xml", StringComparison.OrdinalIgnoreCase)))
                {
                    e.Effects = DragDropEffects.Copy;
                    e.Handled = true;
                    return;
                }
            }
            e.Effects = DragDropEffects.None;
            e.Handled = true;
        }

        private void MainGrid_Drop(object sender, DragEventArgs e)
        {
            if (!e.Data.GetDataPresent(DataFormats.FileDrop))
                return;

            var files = e.Data.GetData(DataFormats.FileDrop) as string[];
            if (files == null)
                return;

            var xmlFile = files.FirstOrDefault(f =>
                Path.GetExtension(f).Equals(".xml", StringComparison.OrdinalIgnoreCase));

            if (xmlFile != null)
            {
                _viewModel?.LoadXmlFromPath(xmlFile);
            }
        }

        private async void InitializeWebView()
        {
            try
            {
                webView.DefaultBackgroundColor = System.Drawing.Color.White;
                await webView.EnsureCoreWebView2Async(null);

                // Przechwytuj drag & drop trafiający bezpośrednio na WebView2
                webView.CoreWebView2.NavigationStarting += WebView_NavigationStarting;
                webView.CoreWebView2.NewWindowRequested += WebView_NewWindowRequested;

                if (_viewModel != null && !string.IsNullOrEmpty(_viewModel.TransformedOutput))
                {
                    DisplayTransformationResult(_viewModel.TransformedOutput);
                }
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show($"Błąd inicjalizacji WebView2: {ex.Message}",
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

        private async void ViewModel_BatchPdfRequested(object? sender, BatchPdfRequestEventArgs e)
        {
            if (e == null || e.Items == null || e.Items.Count == 0)
                return;

            if (webView?.CoreWebView2 == null)
            {
                System.Windows.MessageBox.Show("WebView2 nie jest zainicjalizowany. Spróbuj ponownie.", "Błąd", MessageBoxButton.OK, MessageBoxImage.Warning);
                return;
            }

            int success = 0;
            int fail = 0;
            var errors = new System.Text.StringBuilder();

            // Sekwencyjnie renderuj i drukuj do PDF
            foreach (var (html, outputPath) in e.Items)
            {
                try
                {
                    var tcs = new TaskCompletionSource<bool>();

                    void NavigationHandler(object? s, CoreWebView2NavigationCompletedEventArgs args)
                    {
                        tcs.TrySetResult(args.IsSuccess);
                        webView.NavigationCompleted -= NavigationHandler;
                    }

                    webView.NavigationCompleted += NavigationHandler;
                    webView.NavigateToString(html);

                    // czekaj na zakończenie nawigacji (timeout w razie potrzeby)
                    var navSuccess = await Task.WhenAny(tcs.Task, Task.Delay(TimeSpan.FromSeconds(10))) == tcs.Task && tcs.Task.Result;
                    if (!navSuccess)
                    {
                        throw new Exception("Nawigacja do treści HTML nie powiodła się lub przekroczono limit czasu.");
                    }

                    var printSettings = webView.CoreWebView2.Environment.CreatePrintSettings();
                    printSettings.ShouldPrintBackgrounds = true;
                    printSettings.ShouldPrintHeaderAndFooter = false;

                    bool pdfOk = await webView.CoreWebView2.PrintToPdfAsync(outputPath, printSettings);
                    if (!pdfOk)
                        throw new Exception("PrintToPdfAsync zwrócił false.");

                    success++;
                    _viewModel!.StatusMessage = $"Zapisano PDF: {System.IO.Path.GetFileName(outputPath)}";
                }
                catch (Exception ex)
                {
                    fail++;
                    errors.AppendLine($"• {System.IO.Path.GetFileName(outputPath)}: {ex.Message}");
                }
            }

            var summary = $"Konwersja zakończona. Sukces: {success}, Błędy: {fail}";
            if (fail > 0)
            {
                summary += $"{Environment.NewLine}{Environment.NewLine}Szczegóły błędów:{Environment.NewLine}{errors}";
                System.Windows.MessageBox.Show(summary, "Konwersja do PDF - zakończono", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
            else
            {
                System.Windows.MessageBox.Show(summary, "Konwersja do PDF - zakończono", MessageBoxButton.OK, MessageBoxImage.Information);
            }

            _viewModel!.StatusMessage = summary;
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
                            
                            var result = System.Windows.MessageBox.Show(
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
                            System.Windows.MessageBox.Show(
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
                    System.Windows.MessageBox.Show(
                        "WebView2 nie jest jeszcze zainicjalizowany.",
                        "Błąd",
                        MessageBoxButton.OK,
                        MessageBoxImage.Warning);
                }
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(
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
                    System.Windows.MessageBox.Show(
                        "WebView2 nie jest jeszcze zainicjalizowany.",
                        "Błąd",
                        MessageBoxButton.OK,
                        MessageBoxImage.Warning);
                }
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show(
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
                webView.CoreWebView2.Profile.PreferredColorScheme = CoreWebView2PreferredColorScheme.Light;
            }
        }

        private void WebView_NavigationStarting(object? sender, CoreWebView2NavigationStartingEventArgs e)
        {
            if (IsXmlFileUri(e.Uri))
            {
                e.Cancel = true;
                LoadXmlFromUri(e.Uri);
            }
        }

        private void WebView_NewWindowRequested(object? sender, CoreWebView2NewWindowRequestedEventArgs e)
        {
            // Blokuj każde nowe okno otwierane przez WebView2
            e.Handled = true;
            if (IsXmlFileUri(e.Uri))
            {
                LoadXmlFromUri(e.Uri);
            }
        }

        private static bool IsXmlFileUri(string uri) =>
            uri.StartsWith("file:///", StringComparison.OrdinalIgnoreCase) &&
            uri.EndsWith(".xml", StringComparison.OrdinalIgnoreCase);

        private void LoadXmlFromUri(string uri)
        {
            try
            {
                var filePath = new Uri(uri).LocalPath;
                _viewModel?.LoadXmlFromPath(filePath);
            }
            catch {}
        }

        protected override void OnClosed(EventArgs e)
        {
            if (_viewModel != null)
            {
                _viewModel.PropertyChanged -= ViewModel_PropertyChanged;
                _viewModel.PrintRequested -= ViewModel_PrintRequested;
                _viewModel.PrintPreviewRequested -= ViewModel_PrintPreviewRequested;
                _viewModel.BatchPdfRequested -= ViewModel_BatchPdfRequested;
            }

            if (webView?.CoreWebView2 != null)
            {
                webView.CoreWebView2.NavigationStarting -= WebView_NavigationStarting;
                webView.CoreWebView2.NewWindowRequested -= WebView_NewWindowRequested;
            }

            base.OnClosed(e);
        }
    }
}