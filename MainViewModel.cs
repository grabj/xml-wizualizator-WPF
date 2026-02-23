using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Xml;
using System.Xml.Xsl;
using Microsoft.Win32;
using System.Text;

namespace XmlWizualizator
{
    public class MainViewModel : INotifyPropertyChanged
    {
        #region Pola

        private string? _selectedXmlPath;
        private string? _selectedXslPath;
        private string? _transformedOutput;
        private string? _statusMessage;
        private ViewMode _currentViewMode = ViewMode.Html;
        private string _htmlContent = string.Empty;
        private string? _rawXmlContent;
        private string? _rawXslContent;

        public event EventHandler? PrintRequested;
        public event EventHandler? PrintPreviewRequested;
        public event PropertyChangedEventHandler? PropertyChanged;

        #endregion

        #region Konstruktor i Commands

        public MainViewModel()
        {
            XslFiles = new ObservableCollection<string>();
            LoadXslCommand = new RelayCommand(_ => LoadXslFiles());
            SelectXmlCommand = new RelayCommand(_ => SelectXmlFile());
            TransformCommand = new RelayCommand(_ => TransformXml(), _ => CanTransform());
            ShowPathCommand = new RelayCommand(_ => ShowDiagnostics());
            PrintCommand = new RelayCommand(_ => RequestPrint(), _ => CanPrint());
            PrintPreviewCommand = new RelayCommand(_ => RequestPrintPreview(), _ => CanPrint());

            LoadXslFiles();
        }

        public RelayCommand LoadXslCommand { get; }
        public RelayCommand SelectXmlCommand { get; }
        public RelayCommand TransformCommand { get; }
        public RelayCommand ShowPathCommand { get; }
        public RelayCommand PrintCommand { get; }
        public RelayCommand PrintPreviewCommand { get; }

        #endregion

        #region Właściwości

        public ObservableCollection<string> XslFiles { get; }

        public string? SelectedXmlPath
        {
            get => _selectedXmlPath;
            set
            {
                if (_selectedXmlPath != value)
                {
                    _selectedXmlPath = value;
                    OnPropertyChanged();
                    StatusMessage = $"Wybrano plik XML: {Path.GetFileName(value)}";
                }
            }
        }

        public string? SelectedXslPath
        {
            get => _selectedXslPath;
            set
            {
                if (_selectedXslPath != value)
                {
                    _selectedXslPath = value;
                    OnPropertyChanged();
                    StatusMessage = $"Wybrano szablon XSL: {Path.GetFileName(value)}";
                    
                    if (IsXslMode)
                    {
                        LoadRawXsl();
                    }
                }
            }
        }

        public string? TransformedOutput
        {
            get => _transformedOutput;
            set
            {
                if (_transformedOutput != value)
                {
                    _transformedOutput = value;
                    OnPropertyChanged();
                }
            }
        }

        public string? StatusMessage
        {
            get => _statusMessage;
            set
            {
                if (_statusMessage != value)
                {
                    _statusMessage = value;
                    OnPropertyChanged();
                }
            }
        }

        public string HtmlContent
        {
            get => _htmlContent;
            set
            {
                if (_htmlContent != value)
                {
                    _htmlContent = value;
                    OnPropertyChanged();
                }
            }
        }

        public string? RawXmlContent
        {
            get => _rawXmlContent;
            set
            {
                if (_rawXmlContent != value)
                {
                    _rawXmlContent = value;
                    OnPropertyChanged();
                }
            }
        }

        public string? RawXslContent
        {
            get => _rawXslContent;
            set
            {
                if (_rawXslContent != value)
                {
                    _rawXslContent = value;
                    OnPropertyChanged();
                }
            }
        }

        public enum ViewMode
        {
            Html,      
            Text,
            RawXml,
            RawXsl     
        }

        public ViewMode CurrentViewMode
        {
            get => _currentViewMode;
            set
            {
                if (_currentViewMode != value)
                {
                    _currentViewMode = value;
                    OnPropertyChanged();
                    OnPropertyChanged(nameof(IsTextMode));
                    OnPropertyChanged(nameof(IsHtmlMode));
                    OnPropertyChanged(nameof(IsXmlMode));
                    OnPropertyChanged(nameof(IsXslMode));
                    
                    if (value == ViewMode.RawXml && !string.IsNullOrEmpty(SelectedXmlPath))
                    {
                        LoadRawXml();
                    }
                    else if (value == ViewMode.RawXsl && !string.IsNullOrEmpty(SelectedXslPath))
                    {
                        LoadRawXsl();
                    }
                }
            }
        }

        public bool IsTextMode
        {
            get => CurrentViewMode == ViewMode.Text;
            set { if (value) CurrentViewMode = ViewMode.Text; }
        }

        public bool IsHtmlMode
        {
            get => CurrentViewMode == ViewMode.Html;
            set { if (value) CurrentViewMode = ViewMode.Html; }
        }

        public bool IsXmlMode
        {
            get => CurrentViewMode == ViewMode.RawXml;
            set { if (value) CurrentViewMode = ViewMode.RawXml; }
        }

        public bool IsXslMode
        {
            get => CurrentViewMode == ViewMode.RawXsl;
            set { if (value) CurrentViewMode = ViewMode.RawXsl; }
        }

        #endregion

        #region Metody

        private void LoadXslFiles()
        {
            try
            {
                XslFiles.Clear();
                
                string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                string projectDir = Directory.GetParent(baseDir)?.Parent?.Parent?.Parent?.FullName ?? baseDir;
                
                string[] possiblePaths = 
                {
                    Path.Combine(baseDir, "Xsls"),
                    Path.Combine(projectDir, "Xsls"),
                    Path.Combine(Directory.GetCurrentDirectory(), "Xsls")
                };

                string? xslsPath = null;
                foreach (var path in possiblePaths)
                {
                    if (Directory.Exists(path))
                    {
                        xslsPath = path;
                        break;
                    }
                }
                
                if (xslsPath == null)
                {
                    xslsPath = possiblePaths[0];
                    Directory.CreateDirectory(xslsPath);
                    StatusMessage = $"Utworzono folder: {xslsPath}. Dodaj tam pliki .xsl lub .xslt";
                    
                    MessageBox.Show(
                        $"Folder Xsls nie istniał i został utworzony w:{Environment.NewLine}{xslsPath}{Environment.NewLine}{Environment.NewLine}" +
                        "Umieść tam pliki XSL/XSLT i kliknij 'Odśwież XSL'.",
                        "Informacja",
                        MessageBoxButton.OK,
                        MessageBoxImage.Information);
                    return;
                }

                var xslFiles = Directory.GetFiles(xslsPath, "*.xsl", SearchOption.TopDirectoryOnly)
                    .Concat(Directory.GetFiles(xslsPath, "*.xslt", SearchOption.TopDirectoryOnly))
                    .OrderBy(f => Path.GetFileName(f))
                    .ToList();

                foreach (var file in xslFiles)
                {
                    XslFiles.Add(file);
                }

                if (XslFiles.Count == 0)
                {
                    StatusMessage = $"Nie znaleziono plików XSL w: {xslsPath}";
                    MessageBox.Show(
                        $"Folder Xsls istnieje, ale jest pusty:{Environment.NewLine}{xslsPath}{Environment.NewLine}{Environment.NewLine}" +
                        "Dodaj pliki .xsl lub .xslt do tego folderu.",
                        "Brak plików XSL",
                        MessageBoxButton.OK,
                        MessageBoxImage.Warning);
                }
                else
                {
                    StatusMessage = $"Załadowano {XslFiles.Count} plików XSL z: {xslsPath}";
                }
            }
            catch (Exception ex)
            {
                StatusMessage = $"Błąd ładowania plików XSL: {ex.Message}";
                MessageBox.Show(
                    $"Wystąpił błąd podczas ładowania plików XSL:{Environment.NewLine}{Environment.NewLine}" +
                    $"{ex.Message}",
                    "Błąd",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
            }
        }

        private void SelectXmlFile()
        {
            var openFileDialog = new OpenFileDialog
            {
                Filter = "Pliki XML (*.xml)|*.xml|Wszystkie pliki (*.*)|*.*",
                Title = "Wybierz plik XML"
            };

            if (openFileDialog.ShowDialog() == true)
            {
                SelectedXmlPath = openFileDialog.FileName;
                if (IsXmlMode)
                {
                    LoadRawXml();
                }
            }
        }

        private void LoadRawXml()
        {
            try
            {
                if (!string.IsNullOrEmpty(SelectedXmlPath) && File.Exists(SelectedXmlPath))
                {
                    var xmlDoc = new XmlDocument();
                    xmlDoc.Load(SelectedXmlPath);
                    
                    using var stringWriter = new StringWriter();
                    using var xmlWriter = XmlWriter.Create(stringWriter, new XmlWriterSettings
                    {
                        Indent = true,
                        IndentChars = "  ",
                        NewLineChars = "\r\n",
                        NewLineHandling = NewLineHandling.Replace,
                        Encoding = Encoding.UTF8
                    });
                    
                    xmlDoc.Save(xmlWriter);
                    RawXmlContent = stringWriter.ToString();
                    StatusMessage = $"Załadowano surowy XML: {Path.GetFileName(SelectedXmlPath)}";
                }
            }
            catch (Exception ex)
            {
                RawXmlContent = $"Błąd wczytywania XML:\n{ex.Message}";
                StatusMessage = $"Błąd wczytywania XML: {ex.Message}";
            }
        }

        private void LoadRawXsl()
        {
            try
            {
                if (!string.IsNullOrEmpty(SelectedXslPath) && File.Exists(SelectedXslPath))
                {
                    var xmlDoc = new XmlDocument();
                    xmlDoc.Load(SelectedXslPath);
                    
                    using var stringWriter = new StringWriter();
                    using var xmlWriter = XmlWriter.Create(stringWriter, new XmlWriterSettings
                    {
                        Indent = true,
                        IndentChars = "  ",
                        NewLineChars = "\r\n",
                        NewLineHandling = NewLineHandling.Replace,
                        Encoding = Encoding.UTF8
                    });
                    
                    xmlDoc.Save(xmlWriter);
                    RawXslContent = stringWriter.ToString();
                    StatusMessage = $"Załadowano surowy XSL: {Path.GetFileName(SelectedXslPath)}";
                }
            }
            catch (Exception ex)
            {
                RawXslContent = $"Błąd wczytywania XSL:\n{ex.Message}";
                StatusMessage = $"Błąd wczytywania XSL: {ex.Message}";
            }
        }

        private bool CanTransform()
        {
            return !string.IsNullOrEmpty(SelectedXmlPath) && 
                   !string.IsNullOrEmpty(SelectedXslPath) &&
                   File.Exists(SelectedXmlPath) && 
                   File.Exists(SelectedXslPath);
        }

        private void TransformXml()
        {
            try
            {
                StatusMessage = "Przetwarzanie...";

                var xslTransform = new XslCompiledTransform();
                
                var settings = new XsltSettings(enableDocumentFunction: true, enableScript: true);
                xslTransform.Load(SelectedXslPath!, settings, new XmlUrlResolver());

                using var stringWriter = new StringWriter();
                using var xmlWriter = XmlWriter.Create(stringWriter, new XmlWriterSettings 
                { 
                    Indent = true,
                    OmitXmlDeclaration = false,
                    Encoding = Encoding.UTF8
                });

                xslTransform.Transform(SelectedXmlPath!, xmlWriter);
                
                var transformedContent = stringWriter.ToString();
                
                const string disclaimer = @"
                <div style=""margin-top: 2em; padding: 1em; border-top: 1px solid #333; font-size: 0.9em; text-align: center;"">
                    <strong>Uwaga</strong><br/>
                    Wizualizacja nie reprezentuje przesłanego dokumentu. Jest jedynie wizualną reprezentacją treści zawartej w dokumencie, która nie zawiera żadnych podpisów, ani informacji o podpisach.
                </div>";
                
                if (transformedContent.Contains("</body>", StringComparison.OrdinalIgnoreCase))
                {
                    int bodyCloseIndex = transformedContent.LastIndexOf("</body>", StringComparison.OrdinalIgnoreCase);
                    transformedContent = transformedContent.Insert(bodyCloseIndex, disclaimer);
                }
                
                TransformedOutput = transformedContent;
                HtmlContent = TransformedOutput;
                
                StatusMessage = $"Transformacja zakończona pomyślnie. Rozmiar wyniku: {TransformedOutput.Length} znaków";
            }
            catch (Exception ex)
            {
                StatusMessage = $"Błąd transformacji: {ex.Message}";
                TransformedOutput = $"=== BŁĄD TRANSFORMACJI ===\n{Environment.NewLine}{Environment.NewLine}" +
                                   $"{ex.Message}{Environment.NewLine}{Environment.NewLine}" +
                                   $"Stack Trace:{Environment.NewLine}{ex.StackTrace}";
                
                MessageBox.Show(
                    $"Błąd podczas transformacji XML:{Environment.NewLine}{Environment.NewLine}{ex.Message}", 
                    "Błąd transformacji", 
                    MessageBoxButton.OK, 
                    MessageBoxImage.Error);
            }
        }

        private bool CanPrint()
        {
            return !string.IsNullOrEmpty(TransformedOutput) && IsHtmlMode;
        }

        private void RequestPrint()
        {
            StatusMessage = "Przygotowywanie wydruku...";
            PrintRequested?.Invoke(this, EventArgs.Empty);
        }

        private void RequestPrintPreview()
        {
            StatusMessage = "Otwieranie podglądu wydruku...";
            PrintPreviewRequested?.Invoke(this, EventArgs.Empty);
        }

        private void ShowDiagnostics()
        {
            var message = $"BaseDirectory: {AppDomain.CurrentDomain.BaseDirectory}{Environment.NewLine}" +
                          $"CurrentDirectory: {Directory.GetCurrentDirectory()}{Environment.NewLine}" +
                          $"BaseDirectory + Xsls: {Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Xsls")}{Environment.NewLine}" +
                          $"Folder istnieje: {Directory.Exists(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Xsls"))}";
            
            MessageBox.Show(message, "Diagnostyka ścieżek", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        #endregion
    }
}
