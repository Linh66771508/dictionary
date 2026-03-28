import { useState } from "react";
import {
  Search,
  Plus,
  Edit,
  Trash2,
  Filter,
  BookOpen,
  X,
} from "lucide-react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import { Textarea } from "./ui/textarea";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from "./ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "./ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "./ui/table";
import { Badge } from "./ui/badge";
import { toast } from "sonner";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "./ui/alert-dialog";

interface WordDefinition {
  id: string;
  definition: string;
  example?: string;
}

interface Word {
  id: string;
  word: string;
  partOfSpeech: string;
  definitions: WordDefinition[];
  etymology?: string;
}

const initialWords: Word[] = [
  {
    id: "1",
    word: "yêu",
    partOfSpeech: "động từ",
    definitions: [
      {
        id: "d1",
        definition: "Có tình cảm thiết tha đối với ai",
        example: "Yêu người",
      },
      {
        id: "d2",
        definition: "Thích, ưa chuộng",
        example: "Yêu âm nhạc",
      },
    ],
  },
  {
    id: "2",
    word: "hạnh phúc",
    partOfSpeech: "danh từ",
    definitions: [
      {
        id: "d3",
        definition: "Trạng thái vui vẻ, mãn nguyện về vật chất và tinh thần",
        example: "Cuộc sống hạnh phúc",
      },
    ],
  },
  {
    id: "3",
    word: "tự do",
    partOfSpeech: "danh từ",
    definitions: [
      {
        id: "d4",
        definition: "Không bị ràng buộc, cưỡng bức",
        example: "Tự do ngôn luận",
      },
    ],
  },
];

export default function DictionaryManagement() {
  const [words, setWords] = useState<Word[]>(initialWords);
  const [searchQuery, setSearchQuery] = useState("");
  const [filterPartOfSpeech, setFilterPartOfSpeech] = useState("all");
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [selectedWord, setSelectedWord] = useState<Word | null>(null);
  const [wordToDelete, setWordToDelete] = useState<Word | null>(null);

  // Form states
  const [formData, setFormData] = useState({
    word: "",
    partOfSpeech: "danh từ",
    etymology: "",
    definitions: [{ definition: "", example: "" }],
  });

  const filteredWords = words.filter((word) => {
    const matchesSearch = word.word
      .toLowerCase()
      .includes(searchQuery.toLowerCase());
    const matchesFilter =
      filterPartOfSpeech === "all" ||
      word.partOfSpeech === filterPartOfSpeech;
    return matchesSearch && matchesFilter;
  });

  const handleAddWord = () => {
    const newWord: Word = {
      id: Date.now().toString(),
      word: formData.word,
      partOfSpeech: formData.partOfSpeech,
      etymology: formData.etymology,
      definitions: formData.definitions
        .filter((d) => d.definition.trim() !== "")
        .map((d, index) => ({
          id: `d${Date.now()}-${index}`,
          definition: d.definition,
          example: d.example || undefined,
        })),
    };

    setWords([...words, newWord]);
    setIsAddDialogOpen(false);
    resetForm();
    toast.success(`Đã thêm từ "${formData.word}" thành công`);
  };

  const handleEditWord = () => {
    if (!selectedWord) return;

    const updatedWords = words.map((word) =>
      word.id === selectedWord.id
        ? {
            ...word,
            word: formData.word,
            partOfSpeech: formData.partOfSpeech,
            etymology: formData.etymology,
            definitions: formData.definitions
              .filter((d) => d.definition.trim() !== "")
              .map((d, index) => ({
                id: `d${Date.now()}-${index}`,
                definition: d.definition,
                example: d.example || undefined,
              })),
          }
        : word
    );

    setWords(updatedWords);
    setIsEditDialogOpen(false);
    setSelectedWord(null);
    resetForm();
    toast.success("Đã cập nhật từ thành công");
  };

  const handleDeleteWord = () => {
    if (!wordToDelete) return;

    setWords(words.filter((word) => word.id !== wordToDelete.id));
    setIsDeleteDialogOpen(false);
    setWordToDelete(null);
    toast.success(`Đã xóa từ "${wordToDelete.word}"`);
  };

  const openEditDialog = (word: Word) => {
    setSelectedWord(word);
    setFormData({
      word: word.word,
      partOfSpeech: word.partOfSpeech,
      etymology: word.etymology || "",
      definitions: word.definitions.map((d) => ({
        definition: d.definition,
        example: d.example || "",
      })),
    });
    setIsEditDialogOpen(true);
  };

  const openDeleteDialog = (word: Word) => {
    setWordToDelete(word);
    setIsDeleteDialogOpen(true);
  };

  const resetForm = () => {
    setFormData({
      word: "",
      partOfSpeech: "danh từ",
      etymology: "",
      definitions: [{ definition: "", example: "" }],
    });
  };

  const addDefinitionField = () => {
    setFormData({
      ...formData,
      definitions: [...formData.definitions, { definition: "", example: "" }],
    });
  };

  const removeDefinitionField = (index: number) => {
    setFormData({
      ...formData,
      definitions: formData.definitions.filter((_, i) => i !== index),
    });
  };

  const updateDefinition = (
    index: number,
    field: "definition" | "example",
    value: string
  ) => {
    const updatedDefinitions = [...formData.definitions];
    updatedDefinitions[index][field] = value;
    setFormData({ ...formData, definitions: updatedDefinitions });
  };

  const partOfSpeechOptions = [
    "danh từ",
    "động từ",
    "tính từ",
    "phó từ",
    "đại từ",
    "liên từ",
    "giới từ",
    "thán từ",
  ];

  const WordFormDialog = ({
    isOpen,
    onClose,
    onSubmit,
    title,
  }: {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: () => void;
    title: string;
  }) => (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>
            {title === "Thêm từ mới"
              ? "Nhập thông tin chi tiết về từ mới"
              : "Chỉnh sửa thông tin từ"}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="word">Từ *</Label>
              <Input
                id="word"
                value={formData.word}
                onChange={(e) =>
                  setFormData({ ...formData, word: e.target.value })
                }
                placeholder="Nhập từ"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="partOfSpeech">Loại từ *</Label>
              <Select
                value={formData.partOfSpeech}
                onValueChange={(value) =>
                  setFormData({ ...formData, partOfSpeech: value })
                }
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {partOfSpeechOptions.map((option) => (
                    <SelectItem key={option} value={option}>
                      {option}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="etymology">Nguồn gốc (tùy chọn)</Label>
            <Input
              id="etymology"
              value={formData.etymology}
              onChange={(e) =>
                setFormData({ ...formData, etymology: e.target.value })
              }
              placeholder="Nguồn gốc của từ"
            />
          </div>

          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <Label>Định nghĩa *</Label>
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={addDefinitionField}
              >
                <Plus className="w-4 h-4 mr-2" />
                Thêm định nghĩa
              </Button>
            </div>

            {formData.definitions.map((def, index) => (
              <div key={index} className="border rounded-lg p-4 space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium">
                    Định nghĩa {index + 1}
                  </span>
                  {formData.definitions.length > 1 && (
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => removeDefinitionField(index)}
                    >
                      <X className="w-4 h-4" />
                    </Button>
                  )}
                </div>

                <div className="space-y-2">
                  <Label>Nghĩa</Label>
                  <Textarea
                    value={def.definition}
                    onChange={(e) =>
                      updateDefinition(index, "definition", e.target.value)
                    }
                    placeholder="Nhập định nghĩa"
                    rows={2}
                  />
                </div>

                <div className="space-y-2">
                  <Label>Ví dụ (tùy chọn)</Label>
                  <Input
                    value={def.example}
                    onChange={(e) =>
                      updateDefinition(index, "example", e.target.value)
                    }
                    placeholder="Nhập câu ví dụ"
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Hủy
          </Button>
          <Button
            onClick={onSubmit}
            disabled={
              !formData.word ||
              formData.definitions.every((d) => !d.definition.trim())
            }
          >
            {title === "Thêm từ mới" ? "Thêm từ" : "Cập nhật"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );

  return (
    <div className="p-8">
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Quản lý từ vựng</h1>
            <p className="text-gray-500 mt-2">
              Tra cứu, thêm, sửa, xóa từ trong từ điển
            </p>
          </div>
          <Button
            onClick={() => {
              resetForm();
              setIsAddDialogOpen(true);
            }}
          >
            <Plus className="w-4 h-4 mr-2" />
            Thêm từ mới
          </Button>
        </div>

        <div className="flex gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <Input
              placeholder="Tìm kiếm từ..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10"
            />
          </div>
          <Select value={filterPartOfSpeech} onValueChange={setFilterPartOfSpeech}>
            <SelectTrigger className="w-48">
              <Filter className="w-4 h-4 mr-2" />
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Tất cả loại từ</SelectItem>
              {partOfSpeechOptions.map((option) => (
                <SelectItem key={option} value={option}>
                  {option}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="bg-white rounded-lg border border-gray-200">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[200px]">Từ</TableHead>
              <TableHead className="w-[120px]">Loại từ</TableHead>
              <TableHead>Định nghĩa</TableHead>
              <TableHead className="w-[120px] text-right">Thao tác</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredWords.length === 0 ? (
              <TableRow>
                <TableCell colSpan={4} className="text-center py-8">
                  <BookOpen className="w-12 h-12 mx-auto text-gray-300 mb-2" />
                  <p className="text-gray-500">
                    Không tìm thấy từ nào
                  </p>
                </TableCell>
              </TableRow>
            ) : (
              filteredWords.map((word) => (
                <TableRow key={word.id}>
                  <TableCell className="font-medium">{word.word}</TableCell>
                  <TableCell>
                    <Badge variant="secondary">{word.partOfSpeech}</Badge>
                  </TableCell>
                  <TableCell>
                    <div className="space-y-2">
                      {word.definitions.map((def, index) => (
                        <div key={def.id} className="text-sm">
                          <span className="font-medium">{index + 1}.</span>{" "}
                          {def.definition}
                          {def.example && (
                            <p className="text-gray-500 italic ml-4">
                              Ví dụ: {def.example}
                            </p>
                          )}
                        </div>
                      ))}
                    </div>
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex items-center justify-end gap-2">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openEditDialog(word)}
                      >
                        <Edit className="w-4 h-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openDeleteDialog(word)}
                      >
                        <Trash2 className="w-4 h-4 text-red-500" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      <WordFormDialog
        isOpen={isAddDialogOpen}
        onClose={() => setIsAddDialogOpen(false)}
        onSubmit={handleAddWord}
        title="Thêm từ mới"
      />

      <WordFormDialog
        isOpen={isEditDialogOpen}
        onClose={() => {
          setIsEditDialogOpen(false);
          setSelectedWord(null);
        }}
        onSubmit={handleEditWord}
        title="Chỉnh sửa từ"
      />

      <AlertDialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Xác nhận xóa từ</AlertDialogTitle>
            <AlertDialogDescription>
              Bạn có chắc chắn muốn xóa từ "{wordToDelete?.word}"? Hành động này
              không thể hoàn tác.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Hủy</AlertDialogCancel>
            <AlertDialogAction onClick={handleDeleteWord}>
              Xóa
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
