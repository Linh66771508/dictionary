import { useState } from "react";
import {
  Search,
  Plus,
  Trash2,
  Link2,
  Settings,
} from "lucide-react";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Label } from "./ui/label";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from "./ui/dialog";
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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "./ui/select";
import { Slider } from "./ui/slider";

interface SynonymRelation {
  id: string;
  word1: string;
  word2: string;
  strength: number; // 1-10, mức độ đồng nghĩa
  note?: string;
}

const availableWords = [
  "yêu",
  "thương",
  "mến",
  "quý",
  "đẹp",
  "xinh",
  "tốt",
  "hay",
  "giỏi",
  "khá",
  "hạnh phúc",
  "vui vẻ",
  "tự do",
  "độc lập",
  "thành công",
  "đắc đạo",
  "gia đình",
  "nhà",
  "sợ",
  "lo",
  "buồn",
  "thương tâm",
];

const initialSynonyms: SynonymRelation[] = [
  {
    id: "1",
    word1: "yêu",
    word2: "thương",
    strength: 9,
    note: "Gần nghĩa nhất",
  },
  {
    id: "2",
    word1: "yêu",
    word2: "mến",
    strength: 7,
    note: "Tình cảm nhẹ hơn",
  },
  {
    id: "3",
    word1: "đẹp",
    word2: "xinh",
    strength: 8,
  },
  {
    id: "4",
    word1: "hạnh phúc",
    word2: "vui vẻ",
    strength: 6,
    note: "Khác nhau về mức độ",
  },
  {
    id: "5",
    word1: "tự do",
    word2: "độc lập",
    strength: 7,
  },
];

export default function SynonymManagement() {
  const [synonyms, setSynonyms] = useState<SynonymRelation[]>(initialSynonyms);
  const [searchQuery, setSearchQuery] = useState("");
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [selectedSynonym, setSelectedSynonym] = useState<SynonymRelation | null>(null);
  const [synonymToDelete, setSynonymToDelete] = useState<SynonymRelation | null>(null);

  const [formData, setFormData] = useState({
    word1: "",
    word2: "",
    strength: 5,
    note: "",
  });

  const filteredSynonyms = synonyms.filter((syn) =>
    syn.word1.toLowerCase().includes(searchQuery.toLowerCase()) ||
    syn.word2.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleAddSynonym = () => {
    if (formData.word1 === formData.word2) {
      toast.error("Hai từ phải khác nhau");
      return;
    }

    const newSynonym: SynonymRelation = {
      id: Date.now().toString(),
      word1: formData.word1,
      word2: formData.word2,
      strength: formData.strength,
      note: formData.note || undefined,
    };

    setSynonyms([...synonyms, newSynonym]);
    setIsAddDialogOpen(false);
    resetForm();
    toast.success("Đã thêm quan hệ đồng nghĩa thành công");
  };

  const handleEditSynonym = () => {
    if (!selectedSynonym) return;

    const updatedSynonyms = synonyms.map((syn) =>
      syn.id === selectedSynonym.id
        ? {
            ...syn,
            word1: formData.word1,
            word2: formData.word2,
            strength: formData.strength,
            note: formData.note || undefined,
          }
        : syn
    );

    setSynonyms(updatedSynonyms);
    setIsEditDialogOpen(false);
    setSelectedSynonym(null);
    resetForm();
    toast.success("Đã cập nhật quan hệ đồng nghĩa");
  };

  const handleDeleteSynonym = () => {
    if (!synonymToDelete) return;

    setSynonyms(synonyms.filter((syn) => syn.id !== synonymToDelete.id));
    setIsDeleteDialogOpen(false);
    setSynonymToDelete(null);
    toast.success("Đã xóa quan hệ đồng nghĩa");
  };

  const openEditDialog = (synonym: SynonymRelation) => {
    setSelectedSynonym(synonym);
    setFormData({
      word1: synonym.word1,
      word2: synonym.word2,
      strength: synonym.strength,
      note: synonym.note || "",
    });
    setIsEditDialogOpen(true);
  };

  const openDeleteDialog = (synonym: SynonymRelation) => {
    setSynonymToDelete(synonym);
    setIsDeleteDialogOpen(true);
  };

  const resetForm = () => {
    setFormData({
      word1: "",
      word2: "",
      strength: 5,
      note: "",
    });
  };

  const getStrengthColor = (strength: number) => {
    if (strength >= 8) return "bg-green-100 text-green-800";
    if (strength >= 5) return "bg-yellow-100 text-yellow-800";
    return "bg-orange-100 text-orange-800";
  };

  const getStrengthLabel = (strength: number) => {
    if (strength >= 8) return "Rất gần nghĩa";
    if (strength >= 5) return "Tương tự";
    return "Liên quan";
  };

  const SynonymFormDialog = ({
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
      <DialogContent className="max-w-lg">
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>
            {title === "Thêm quan hệ đồng nghĩa"
              ? "Chọn hai từ để tạo mối liên hệ đồng nghĩa"
              : "Chỉnh sửa mức độ đồng nghĩa"}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="word1">Từ thứ nhất *</Label>
              <Select
                value={formData.word1}
                onValueChange={(value) =>
                  setFormData({ ...formData, word1: value })
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Chọn từ" />
                </SelectTrigger>
                <SelectContent>
                  {availableWords.map((word) => (
                    <SelectItem key={word} value={word}>
                      {word}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="word2">Từ thứ hai *</Label>
              <Select
                value={formData.word2}
                onValueChange={(value) =>
                  setFormData({ ...formData, word2: value })
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="Chọn từ" />
                </SelectTrigger>
                <SelectContent>
                  {availableWords.map((word) => (
                    <SelectItem key={word} value={word}>
                      {word}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <Label>Mức độ đồng nghĩa: {formData.strength}/10</Label>
              <Badge className={getStrengthColor(formData.strength)}>
                {getStrengthLabel(formData.strength)}
              </Badge>
            </div>
            <Slider
              value={[formData.strength]}
              onValueChange={(value) =>
                setFormData({ ...formData, strength: value[0] })
              }
              min={1}
              max={10}
              step={1}
              className="w-full"
            />
            <p className="text-xs text-gray-500">
              1 = Liên quan nhẹ, 10 = Hoàn toàn đồng nghĩa
            </p>
          </div>

          <div className="space-y-2">
            <Label htmlFor="note">Ghi chú (tùy chọn)</Label>
            <Input
              id="note"
              value={formData.note}
              onChange={(e) =>
                setFormData({ ...formData, note: e.target.value })
              }
              placeholder="Thêm ghi chú về mối quan hệ"
            />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Hủy
          </Button>
          <Button
            onClick={onSubmit}
            disabled={!formData.word1 || !formData.word2}
          >
            {title === "Thêm quan hệ đồng nghĩa" ? "Thêm" : "Cập nhật"}
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
            <h1 className="text-3xl font-bold text-gray-900">
              Quản lý đồng nghĩa
            </h1>
            <p className="text-gray-500 mt-2">
              Tạo và quản lý mối liên hệ đồng nghĩa giữa các từ
            </p>
          </div>
          <Button
            onClick={() => {
              resetForm();
              setIsAddDialogOpen(true);
            }}
          >
            <Plus className="w-4 h-4 mr-2" />
            Thêm quan hệ mới
          </Button>
        </div>

        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <Input
            placeholder="Tìm kiếm từ đồng nghĩa..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
      </div>

      <div className="bg-white rounded-lg border border-gray-200">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[200px]">Từ 1</TableHead>
              <TableHead className="w-[80px] text-center">
                <Link2 className="w-4 h-4 mx-auto" />
              </TableHead>
              <TableHead className="w-[200px]">Từ 2</TableHead>
              <TableHead className="w-[150px]">Mức độ</TableHead>
              <TableHead>Ghi chú</TableHead>
              <TableHead className="w-[120px] text-right">Thao tác</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredSynonyms.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="text-center py-8">
                  <Link2 className="w-12 h-12 mx-auto text-gray-300 mb-2" />
                  <p className="text-gray-500">
                    Không tìm thấy quan hệ đồng nghĩa
                  </p>
                </TableCell>
              </TableRow>
            ) : (
              filteredSynonyms.map((synonym) => (
                <TableRow key={synonym.id}>
                  <TableCell className="font-medium">
                    {synonym.word1}
                  </TableCell>
                  <TableCell className="text-center">
                    <div className="flex items-center justify-center">
                      <div className="w-8 border-t-2 border-gray-300"></div>
                    </div>
                  </TableCell>
                  <TableCell className="font-medium">
                    {synonym.word2}
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      <Badge className={getStrengthColor(synonym.strength)}>
                        {synonym.strength}/10
                      </Badge>
                      <span className="text-xs text-gray-500">
                        {getStrengthLabel(synonym.strength)}
                      </span>
                    </div>
                  </TableCell>
                  <TableCell className="text-sm text-gray-600">
                    {synonym.note || "-"}
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex items-center justify-end gap-2">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openEditDialog(synonym)}
                      >
                        <Settings className="w-4 h-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => openDeleteDialog(synonym)}
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

      <SynonymFormDialog
        isOpen={isAddDialogOpen}
        onClose={() => setIsAddDialogOpen(false)}
        onSubmit={handleAddSynonym}
        title="Thêm quan hệ đồng nghĩa"
      />

      <SynonymFormDialog
        isOpen={isEditDialogOpen}
        onClose={() => {
          setIsEditDialogOpen(false);
          setSelectedSynonym(null);
        }}
        onSubmit={handleEditSynonym}
        title="Chỉnh sửa quan hệ đồng nghĩa"
      />

      <AlertDialog
        open={isDeleteDialogOpen}
        onOpenChange={setIsDeleteDialogOpen}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Xác nhận xóa quan hệ</AlertDialogTitle>
            <AlertDialogDescription>
              Bạn có chắc chắn muốn xóa quan hệ đồng nghĩa giữa "
              {synonymToDelete?.word1}" và "{synonymToDelete?.word2}"?
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Hủy</AlertDialogCancel>
            <AlertDialogAction onClick={handleDeleteSynonym}>
              Xóa
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
